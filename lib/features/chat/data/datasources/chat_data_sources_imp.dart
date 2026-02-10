// lib/features/chat/data/datasources/chat_datasources_imp.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import 'package:logging/logging.dart' as logging;

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

  // ============ SIGNALR METHODS ============


  
  Future<void> connectSignalR(String token) async {
    try {
      if (_hubConnection?.state == HubConnectionState.Connected) {
        print('⚠️ SignalR ya está conectado');
        return;
      }

      final hubUrl = '$defaultApiServer/chathub';

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () => Future.value(token),
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Eventos de conexión
      _hubConnection!.onclose(({Exception? error}) {
        print('❌ SignalR cerrado: ${error?.toString() ?? 'Conexión cerrada'}');
      });

      _hubConnection!.onreconnecting(({Exception? error}) {
        print('🔄 SignalR reconectando...');
      });

      _hubConnection!.onreconnected(({String? connectionId}) {
        print('✅ SignalR reconectado');
      });

      // Escuchar mensajes
      _hubConnection!.on('ReceiveMessage', _handleReceiveMessage);

      // Conectar
      await _hubConnection!.start();
      print('✅ SignalR conectado exitosamente');
      
    } catch (e) {
      print('❌ Error conectando SignalR: $e');
      throw Exception('Error al conectar SignalR: $e');
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

  // Procesar mensaje recibido de SignalR
  void _handleReceiveMessage(List<Object?>? arguments) {
    try {
      if (arguments == null || arguments.isEmpty) {
        print('⚠️ Mensaje vacío recibido');
        return;
      }

      print('📨 Mensaje crudo recibido: $arguments');

      final messageData = arguments[0] as Map<String, dynamic>;
      
      // Convertir a MensajeEntity usando el modelo
      final mensaje = MensajeModel.fromJson(messageData);
      
      // Llamar al callback si existe
      if (_onMessageReceived != null) {
        _onMessageReceived!(mensaje);
      }
      
    } catch (e) {
      print('❌ Error procesando mensaje de SignalR: $e');
    }
  }
}