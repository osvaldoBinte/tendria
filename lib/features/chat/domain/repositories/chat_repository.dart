// lib/features/chat/domain/repositories/chat_repository.dart

import 'package:tendria/features/chat/domain/entities/chat_entity.dart';
import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/domain/entities/post_chat_entity.dart';

abstract class ChatRepository {
  // REST API methods
  Future<ChatEntity> chatmensaje(int chatid);
  Future<void> postchat(PostChatEntity entity);
  
  // SignalR methods
  Future<void> connectSignalR(String token);
  Future<void> disconnectSignalR();
  Future<void> joinChat(int chatId);
  Future<void> leaveChat(int chatId);
  void setMessageCallback(Function(MensajeEntity) callback);
  bool get isSignalRConnected;
}