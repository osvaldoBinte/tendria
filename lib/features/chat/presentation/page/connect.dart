import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/domain/usecase/connect_signalr_usecase.dart';
import 'package:tendria/features/chat/domain/usecase/disconnect_signalr_usecase.dart';
import 'package:tendria/features/chat/domain/usecase/join_chat_usecase.dart';
import 'package:tendria/features/chat/domain/usecase/leave_chat_usecase.dart';
import 'package:tendria/features/chat/domain/usecase/marcar_mensajes_leidos_usecase.dart';
import 'package:tendria/features/chat/domain/usecase/on_mensajes_leidos_usecase.dart';
import 'package:tendria/features/chat/domain/usecase/setup_message_listener_usecase.dart';
import 'package:tendria/features/chat/domain/usecase/set_on_disconnected_callback_usecase.dart';

class SignalRService extends GetxService with WidgetsBindingObserver {
  // ── Usecases ──
  final ConnectSignalRUsecase connectSignalRUsecase;
  final DisconnectSignalRUsecase disconnectSignalRUsecase;
  final JoinChatUsecase joinChatUsecase;
  final LeaveChatUsecase leaveChatUsecase;
  final SetupMessageListenerUsecase setupMessageListenerUsecase;
  final SetOnDisconnectedCallbackUsecase setOnDisconnectedCallbackUsecase;
  final OnMensajesLeidosUsecase onMensajesLeidosUsecase;
  final MarcarMensajesLeidosUsecase marcarMensajesLeidosUsecase;
   AuthService authService = AuthService();

  SignalRService({
    required this.connectSignalRUsecase,
    required this.disconnectSignalRUsecase,
    required this.joinChatUsecase,
    required this.leaveChatUsecase,
    required this.setupMessageListenerUsecase,
    required this.setOnDisconnectedCallbackUsecase,
    required this.onMensajesLeidosUsecase,
    required this.marcarMensajesLeidosUsecase,
  });
bool _isConnecting = false; 
Completer<void>? _connectionCompleter;

  final RxBool isConnected = false.obs;

  // ── Listeners ──
  final Map<int, Function(MensajeEntity)> _chatListeners = {};
  Function(MensajeEntity)? _globalListener;

  // ── Reconexión ──
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
final RxBool isReconnecting = false.obs; // 👈 público y reactivo


  // ─────────────────────────────────────────
  //  CICLO DE VIDA
  // ─────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _connectIfAuthenticated();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        print('📱 App en segundo plano');
        break;
      default:
        break;
    }
  }

Future<void> _onAppResumed() async {
  print('📱 App en primer plano - verificando SignalR...');
  
  // 👇 Si el proceso de reconexión anterior murió (app en bg agotó reintentos)
  // resetear para dar una oportunidad fresca
  if (!isConnected.value) {
    isReconnecting.value = false;
    _reconnectAttempts = 0;
    await _reconnect();
  }
}

  // ─────────────────────────────────────────
  //  CONEXIÓN
  // ─────────────────────────────────────────

  Future<void> _connectIfAuthenticated() async {
    final token = await authService.getToken();
    if (token != null) {
      await connect(token);
    }
  }
Future<void> connect(String token) async {
  if (isConnected.value || _isConnecting) return; // 👈 evitar doble llamada
  _isConnecting = true;
  try {
    await connectSignalRUsecase.execute(token);
    setupMessageListenerUsecase.execute(_routeMessage);
    setOnDisconnectedCallbackUsecase.execute(_onUnexpectedDisconnect);
    isConnected.value = true;
    _reconnectAttempts = 0;
    print('✅ SignalR conectado');
  } catch (e) {
    isConnected.value = false;
    print('❌ Error conectando SignalR: $e');
  } finally {
    _isConnecting = false; // 👈 siempre liberar
  }
}

  // ─────────────────────────────────────────
  //  DESCONEXIÓN INESPERADA
  // ─────────────────────────────────────────

  void _onUnexpectedDisconnect() {
    if (isReconnecting.value) return; // evitar múltiples reconexiones simultáneas
    print('⚠️ SignalR desconectado inesperadamente');
    isConnected.value = false;
    _scheduleReconnect();
  }

  Future<void> _scheduleReconnect() async {
  if (_reconnectAttempts >= _maxReconnectAttempts) {
    _reconnectAttempts = 0;
    isReconnecting.value = false; // 👈
    return;
  }
  isReconnecting.value = true; // 👈
  final delay = Duration(seconds: (2 << _reconnectAttempts));
  _reconnectAttempts++;
  await Future.delayed(delay);
  await _reconnect();
}


  Future<void> _reconnect() async {
      if (isConnected.value || _isConnecting) return; // 👈 mismo guard

    final token = await authService.getToken();
    if (token == null) {
      print('⚠️ No hay token disponible para reconectar');
      isReconnecting.value = false;
      return;
    }

    try {
      await connectSignalRUsecase.execute(token);
      setupMessageListenerUsecase.execute(_routeMessage);
      setOnDisconnectedCallbackUsecase.execute(_onUnexpectedDisconnect);
      isConnected.value = true;
      _reconnectAttempts = 0;
      isReconnecting.value = false;

      // Rejoinear todos los chats que estaban activos
      for (final chatId in _chatListeners.keys) {
        try {
          await joinChatUsecase.execute(chatId);
          print('✅ Re-unido al chat #$chatId');
        } catch (e) {
          print('❌ Error re-uniéndose al chat #$chatId: $e');
        }
      }

      print('✅ SignalR reconectado con ${_chatListeners.length} chats activos');
    } catch (e) {
      isConnected.value = false;
      print('❌ Reintento $_reconnectAttempts falló: $e');
      await _scheduleReconnect(); // volver a intentar con más delay
    }
  }

  // ─────────────────────────────────────────
  //  SUSCRIPCIONES
  // ─────────────────────────────────────────

Future<void> subscribeToChat(int chatId, Function(MensajeEntity) callback) async {
  // Si está en proceso de conexión, esperar a que termine
  if (_isConnecting && _connectionCompleter != null) {
    print('⏳ Esperando conexión en curso...');
    try {
      await _connectionCompleter!.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Timeout esperando SignalR'),
      );
    } catch (e) {
      print('❌ Error esperando conexión: $e');
    }
  }

  // Si aún no conectó, intentar una vez más
  if (!isConnected.value) {
    await _reconnect();
    if (!isConnected.value) {
      throw Exception('SignalR no está disponible');
    }
  }

  _chatListeners[chatId] = callback;
  await joinChatUsecase.execute(chatId);
  print('✅ Suscrito al chat #$chatId');
}
  Future<void> unsubscribeFromChat(int chatId) async {
    _chatListeners.remove(chatId);
    try {
      await leaveChatUsecase.execute(chatId);
      print('👋 Desuscrito del chat #$chatId');
    } catch (e) {
      print('❌ Error desuscribiéndose del chat #$chatId: $e');
    }
  }

  void setGlobalListener(Function(MensajeEntity) callback) {
    _globalListener = callback;
  }

  void removeGlobalListener() {
    _globalListener = null;
  }

  // ─────────────────────────────────────────
  //  ENRUTAMIENTO DE MENSAJES
  // ─────────────────────────────────────────

  void _routeMessage(MensajeEntity mensaje) {
    // Mandar al chat específico si está abierto
    _chatListeners[mensaje.chatId]?.call(mensaje);
    // Siempre notificar al listener global (badges, lista de chats)
    _globalListener?.call(mensaje);
  }
  // En SignalRService
Future<void> disconnect() async {
  try {
    isReconnecting.value = false;
    _reconnectAttempts = _maxReconnectAttempts; // evitar auto-reconexión
    
    // Salir de todos los chats activos
    for (final chatId in _chatListeners.keys.toList()) {
      try {
        await leaveChatUsecase.execute(chatId);
      } catch (_) {}
    }
    _chatListeners.clear();
    _globalListener = null;

    await disconnectSignalRUsecase.execute();
    isConnected.value = false;
    print('✅ SignalR desconectado por logout');
  } catch (e) {
    print('❌ Error desconectando SignalR: $e');
  }
}
 Future<void> marcarMensajesLeidos(int chatId, int otroUserId) async {
    if (!isConnected.value) return;
    await marcarMensajesLeidosUsecase.execute(chatId, otroUserId);
  }

  // ✅ Registrar listener del evento MensajesLeidos
  void escucharMensajesLeidos(Function(DateTime) callback) {
    print('👂 Registrando listener para mensajes leídos');
    onMensajesLeidosUsecase.execute(callback);
  }


}