 
import 'dart:ui';

import 'package:tendria/features/chat/domain/entities/chat_entity.dart';
import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/domain/entities/post_chat_entity.dart';

abstract class ChatRepository {
  
  Future<ChatEntity> chatmensaje(int chatid);
  Future<void> postchat(PostChatEntity entity);
  Future<List<ChatEntity>> getMyChats();
   
  Future<void> connectSignalR(String token);
  Future<void> disconnectSignalR();
  Future<void> joinChat(int chatId);
  Future<void> leaveChat(int chatId);
  void setMessageCallback(Function(MensajeEntity) callback);
  bool get isSignalRConnected;
  void setOnDisconnectedCallback(VoidCallback callback);
  void onMensajesLeidos(Function(DateTime leidoEn) callback);
Future<void> marcarMensajesLeidos(int chatId, int otroUserId);
}