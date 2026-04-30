// lib/features/chat/data/datasources/chat_datasources_imp.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/signalr_client.dart';
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/errors/api_errors.dart';
import 'package:tendria/features/chat/data/model/chat_model.dart';
import 'package:tendria/features/chat/data/model/mensaje_model.dart';
import 'package:tendria/features/chat/data/model/post_chat_model.dart';
import 'package:tendria/features/chat/domain/entities/chat_entity.dart';
import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/domain/entities/post_chat_entity.dart';

class ChatDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;

  HubConnection? _hubConnection;
  Function(MensajeEntity)? _onMessageReceived;
  Function(DateTime)? _onMensajesLeidosCallback;
  VoidCallback? _onDisconnectedCallback;

  // ============ REST API METHODS ============

  Future<void> sendmessage(PostChatEntity entity, String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Mensajes');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(PostChatModel.fromEntity(entity).toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) return;
      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e) {
      if (e is SocketException || e is http.ClientException || e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }
  }

  Future<ChatEntity> chatmensaje(int chatid, String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Mensajes/chat/$chatid');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        return ChatModel.fromJson(jsonDecode(dataUTF8));
      }
      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e) {
      if (e is SocketException || e is http.ClientException || e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }
  }

  Future<List<ChatEntity>> getmychats(String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Mensajes/mis-chats');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final List data = jsonDecode(dataUTF8);
        return data.map((json) => ChatModel.fromJson(json)).toList();
      }
      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e) {
      if (e is SocketException || e is http.ClientException || e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }
  }

  // ============ SIGNALR METHODS ============

  Future<void> connectSignalR(String token) async {
    // Si ya está conectado, no hacer nada
    if (_hubConnection?.state == HubConnectionState.Connected) {
      print('⚠️ SignalR ya está conectado');
      return;
    }

    // Detener y limpiar conexión anterior si existe
    await _cleanupConnection();

    final hubUrl = '$defaultApiServer/chathub';
    print('🔌 Conectando SignalR a $hubUrl...');

    // ⚠️ SIN withAutomaticReconnect — lo maneja SignalRService
    _hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () => Future.value(token),
            transport: HttpTransportType.LongPolling,
            logMessageContent: false,
            requestTimeout: 30000,
          ),
        )
        .build();

    // Registrar eventos de lifecycle
    _hubConnection!.onclose(({Exception? error}) {
      print('❌ SignalR cerrado: ${error?.toString() ?? 'sin error'}');
      _onDisconnectedCallback?.call();
    });

    // Registrar listeners de mensajes ANTES de conectar
    _registerAllListeners();

    await _hubConnection!.start();
    print('✅ SignalR conectado - ID: ${_hubConnection!.connectionId}');
  }

  /// Limpia la conexión anterior de forma segura
  Future<void> _cleanupConnection() async {
    if (_hubConnection == null) return;
    try {
      final conn = _hubConnection;
      _hubConnection = null;
      await conn?.stop();
    } catch (e) {
      print('⚠️ Error limpiando conexión anterior: $e');
    }
  }

  /// Registra todos los listeners sobre la conexión actual.
  /// Se llama tras conectar y tras reconectar.
  void _registerAllListeners() {
    if (_hubConnection == null) return;

    _hubConnection!.off('ReceiveMessage');
    _hubConnection!.off('MensajesLeidos');

    _hubConnection!.on('ReceiveMessage', _handleReceiveMessage);
    _hubConnection!.on('MensajesLeidos', _handleMensajesLeidos);

    print('✅ Listeners SignalR registrados');
  }

  Future<void> disconnectSignalR() async {
    _onDisconnectedCallback = null;
    await _cleanupConnection();
    _onMessageReceived = null;
    print('👋 SignalR desconectado por logout');
  }

  Future<void> joinChat(int chatId) async {
    if (_hubConnection?.state != HubConnectionState.Connected) {
      throw Exception('SignalR no está conectado');
    }
    await _hubConnection!.invoke('JoinChat', args: [chatId]);
    print('✅ Unido al chat #$chatId');
  }

  Future<void> leaveChat(int chatId) async {
    try {
      if (_hubConnection?.state == HubConnectionState.Connected) {
        await _hubConnection!.invoke('LeaveChat', args: [chatId]);
        print('👋 Saliste del chat #$chatId');
      }
    } catch (e) {
      print('⚠️ Error saliendo del chat #$chatId: $e');
    }
  }

  void setMessageCallback(Function(MensajeEntity) callback) {
    _onMessageReceived = callback;
  }

  bool get isSignalRConnected {
    return _hubConnection?.state == HubConnectionState.Connected;
  }

  void setOnDisconnectedCallback(VoidCallback callback) {
    // Guardamos la referencia para re-asignarla tras reconexión
    _onDisconnectedCallback = callback;
  }

  // ── Marcar como leídos ──
  Future<void> marcarMensajesLeidos(int chatId, int otroUserId) async {
    try {
      if (_hubConnection?.state != HubConnectionState.Connected) return;
      await _hubConnection!.invoke('MarcarComoLeidos', args: [chatId, otroUserId]);
    } catch (e) {
      print('❌ Error en MarcarComoLeidos: $e');
    }
  }

  // ── Registrar listener MensajesLeidos ──
  void onMensajesLeidos(Function(DateTime leidoEn) callback) {
    _onMensajesLeidosCallback = callback;
    // Si la conexión ya existe, registrar de inmediato
    if (_hubConnection != null) {
      _hubConnection!.off('MensajesLeidos');
      _hubConnection!.on('MensajesLeidos', _handleMensajesLeidos);
    }
  }

  // ============ HANDLERS PRIVADOS ============

  void _handleReceiveMessage(List<Object?>? arguments) {
    try {
      if (arguments == null || arguments.isEmpty) return;

      Map<String, dynamic> messageData;
      final raw = arguments[0];

      if (raw is String) {
        messageData = jsonDecode(raw);
      } else if (raw is Map<String, dynamic>) {
        messageData = raw;
      } else {
        messageData = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
      }

      messageData = _fixEncodingInMap(messageData);
      final mensaje = MensajeModel.fromJson(messageData);
      _onMessageReceived?.call(mensaje);
    } catch (e) {
      print('❌ Error procesando ReceiveMessage: $e');
    }
  }

  void _handleMensajesLeidos(List<Object?>? args) {
    try {
      final raw = args?[0];
      final leidoEn = raw is String ? DateTime.parse(raw) : DateTime.now();
      _onMensajesLeidosCallback?.call(leidoEn);
    } catch (e) {
      print('❌ Error parseando MensajesLeidos: $e');
    }
  }

  Map<String, dynamic> _fixEncodingInMap(Map<String, dynamic> map) {
    final fixed = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is String) {
        try {
          fixed[key] = utf8.decode(latin1.encode(value));
        } catch (_) {
          fixed[key] = value;
        }
      } else if (value is Map<String, dynamic>) {
        fixed[key] = _fixEncodingInMap(value);
      } else {
        fixed[key] = value;
      }
    });
    return fixed;
  }
}