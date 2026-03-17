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
  
  // SignalR connection
  HubConnection? _hubConnection;
  Function(MensajeEntity)? _onMessageReceived;

  // ============ REST API METHODS ============
  
  Future<void> sendmessage(PostChatEntity entity, String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Mensajes');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(PostChatModel.fromEntity(entity).toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
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
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);
        return ChatModel.fromJson(responseDecode);
      }
      
      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
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
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
         final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        final List data = responseDecode;
        return data.map((json) => ChatModel.fromJson(json)).toList();
      }
      
      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }
  }

  // ============ SIGNALR METHODS ============

  Future<void> connectSignalR(String token) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        // Si ya está conectado, salir
        if (_hubConnection?.state == HubConnectionState.Connected) {
          print('⚠️ SignalR ya está conectado');
          return;
        }

        final hubUrl = '$defaultApiServer/chathub';
        
        print('🔌 Intento ${retryCount + 1}/$maxRetries - Conectando SignalR...');
        
        // Esperar antes de reintentar (excepto el primer intento)
        if (retryCount > 0) {
          print('⏳ Esperando ${retryCount} segundos antes de reintentar...');
          await Future.delayed(Duration(seconds: retryCount));
        }

        // Crear nueva conexión
        _hubConnection = HubConnectionBuilder()
            .withUrl(
              hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () => Future.value(token),
                transport: HttpTransportType.LongPolling, // 👈 Más estable
                logMessageContent: true,
                requestTimeout: 100000, // 100 segundos
              ),
            )
            .withAutomaticReconnect(retryDelays: [
              2000,  // 2 segundos
              5000,  // 5 segundos
              10000, // 10 segundos
              30000, // 30 segundos
            ])
            .build();

        // Eventos de conexión
        _hubConnection!.onclose(({Exception? error}) {
          print('❌ SignalR cerrado: ${error?.toString() ?? 'Conexión cerrada'}');
        });

        _hubConnection!.onreconnecting(({Exception? error}) {
          print('🔄 SignalR reconectando...');
        });

        _hubConnection!.onreconnected(({String? connectionId}) {
          print('✅ SignalR reconectado - Connection ID: $connectionId');
        });

        // Escuchar mensajes
        _hubConnection!.on('ReceiveMessage', _handleReceiveMessage);

        // ⚠️ ESTE ES EL PUNTO CRÍTICO QUE FALLA LA PRIMERA VEZ
        print('🚀 Iniciando conexión SignalR...');
        await _hubConnection!.start();
        
        print('✅ SignalR conectado exitosamente!');
        print('   Connection ID: ${_hubConnection!.connectionId}');
        
        // ✅ Si llegamos aquí, salir del loop
        return;
        
      } catch (e) {
        retryCount++;
        
        print('⚠️ Intento $retryCount falló: $e');
        
        // Si es el último intento, lanzar el error
        if (retryCount >= maxRetries) {
          print('❌ Error conectando SignalR después de $maxRetries intentos');
          throw Exception('Error al conectar SignalR después de $maxRetries intentos: $e');
        }
        
        // Limpiar la conexión fallida
        try {
          await _hubConnection?.stop();
          _hubConnection = null;
        } catch (_) {
          // Ignorar errores al limpiar
        }
        
        print('🔄 Reintentando conexión...');
      }
    }
  }

  Future<void> disconnectSignalR() async {
    try {
      if (_hubConnection != null) {
        await _hubConnection!.stop();
        _hubConnection = null;
        _onMessageReceived = null;
        print('👋 SignalR desconectado');
      }
    } catch (e) {
      print('❌ Error desconectando SignalR: $e');
      throw Exception('Error al desconectar SignalR: $e');
    }
  }

  Future<void> joinChat(int chatId) async {
    try {
      if (_hubConnection?.state != HubConnectionState.Connected) {
        throw Exception('SignalR no está conectado');
      }

      await _hubConnection!.invoke('JoinChat', args: [chatId]);
      print('✅ Unido al chat #$chatId');
      
    } catch (e) {
      print('❌ Error uniéndose al chat: $e');
      throw Exception('Error al unirse al chat: $e');
    }
  }

  Future<void> leaveChat(int chatId) async {
    try {
      if (_hubConnection?.state == HubConnectionState.Connected) {
        await _hubConnection!.invoke('LeaveChat', args: [chatId]);
        print('👋 Saliste del chat #$chatId');
      }
    } catch (e) {
      print('❌ Error saliendo del chat: $e');
      // No lanzar excepción aquí, solo log
    }
  }

  void setMessageCallback(Function(MensajeEntity) callback) {
    _onMessageReceived = callback;
  }

  bool get isSignalRConnected {
    return _hubConnection?.state == HubConnectionState.Connected;
  }

void _handleReceiveMessage(List<Object?>? arguments) {
  try {
    if (arguments == null || arguments.isEmpty) {
      print('⚠️ Mensaje vacío recibido');
      return;
    }

    print('📨 Mensaje crudo recibido: $arguments');

    Map<String, dynamic> messageData;

    final raw = arguments[0];

    if (raw is String) {
      // ✅ Si llega como String, decodifica UTF-8 correctamente
      final bytes = utf8.encode(raw);
      final decoded = utf8.decode(bytes);
      messageData = jsonDecode(decoded);
    } else if (raw is Map<String, dynamic>) {
      // ✅ Si llega como Map, re-serializa y decodifica para corregir acentos
      final jsonStr = jsonEncode(raw);
      final bytes = utf8.encode(jsonStr);
      final decoded = utf8.decode(bytes);
      messageData = jsonDecode(decoded);
    } else {
      // ✅ Fallback: convierte a JSON string y decodifica
      final jsonStr = jsonEncode(raw);
      final bytes = utf8.encode(jsonStr);
      final decoded = utf8.decode(bytes);
      messageData = jsonDecode(decoded) as Map<String, dynamic>;
    }

    // Corregir acentos en campos de texto específicos
    messageData = _fixEncodingInMap(messageData);

    final mensaje = MensajeModel.fromJson(messageData);

    if (_onMessageReceived != null) {
      _onMessageReceived!(mensaje);
    }

  } catch (e) {
    print('❌ Error procesando mensaje de SignalR: $e');
  }
}

// ✅ Corrige encoding en todos los campos String del Map
Map<String, dynamic> _fixEncodingInMap(Map<String, dynamic> map) {
  final fixed = <String, dynamic>{};
  
  map.forEach((key, value) {
    if (value is String) {
      try {
        // Intenta corregir Latin-1 mal interpretado como UTF-8
        final bytes = latin1.encode(value);
        fixed[key] = utf8.decode(bytes);
      } catch (_) {
        fixed[key] = value; // Si falla, deja el valor original
      }
    } else if (value is Map<String, dynamic>) {
      fixed[key] = _fixEncodingInMap(value);
    } else {
      fixed[key] = value;
    }
  });
  
  return fixed;
}
  void setOnDisconnectedCallback(VoidCallback callback) {
  _hubConnection?.onclose(({Exception? error}) {
    print('❌ SignalR cerrado: ${error?.toString()}');
    callback();
  });
}
// ── Marcar como leídos (invoca el Hub) ──
Future<void> marcarMensajesLeidos(int chatId, int otroUserId) async {
  try {
    if (_hubConnection?.state != HubConnectionState.Connected) return;
    await _hubConnection!.invoke('MarcarComoLeidos', args: [chatId, otroUserId]);
    print('✅ MarcarComoLeidos invocado');
  } catch (e) {
    print('❌ Error en MarcarComoLeidos: $e');
  }
}

// ── Escuchar evento MensajesLeidos del servidor ──
// Agregar campo
Function(DateTime)? _onMensajesLeidosCallback;

void onMensajesLeidos(Function(DateTime leidoEn) callback) {
  _onMensajesLeidosCallback = callback; // ✅ guardar referencia
  _registrarListenerMensajesLeidos();
}

void _registrarListenerMensajesLeidos() {
  if (_hubConnection == null) return;
  // Quitar listener anterior para no duplicar
  _hubConnection!.off('MensajesLeidos');
  _hubConnection!.on('MensajesLeidos', (args) {
    try {
      print('👁️ Evento MensajesLeidos recibido: $args');
      final raw = args?[0];
      final leidoEn = raw is String
          ? DateTime.parse(raw)
          : DateTime.now();
      _onMensajesLeidosCallback?.call(leidoEn);
    } catch (e) {
      print('❌ Error parseando MensajesLeidos: $e');
    }
  });
  print('✅ Listener MensajesLeidos registrado');
}
}