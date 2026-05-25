import 'dart:ui';

import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/features/chat/data/datasources/chat_data_sources_imp.dart';
import 'package:tendria/features/chat/domain/entities/chat_entity.dart';
import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/domain/entities/post_chat_entity.dart';
import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImp implements ChatRepository {

  final ChatDataSourcesImp chatDataSourcesImp;
  final AuthService authService = AuthService();
  ChatRepositoryImp({
    required this.chatDataSourcesImp,
   
  }); 

  @override
  Future<ChatEntity> chatmensaje(int chatid) async {
        final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));

    return chatDataSourcesImp.chatmensaje(chatid, token);
  }

  @override
  Future<void> postchat(PostChatEntity entity) async {
        final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));

    return chatDataSourcesImp.sendmessage(entity, token);
  }
  @override
  Future<List<ChatEntity>> getMyChats() async {
    final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return chatDataSourcesImp.getmychats(token);
  }
  
   

  @override
  Future<void> connectSignalR(String token) async {
    return await chatDataSourcesImp.connectSignalR(token);
  }

  @override
  Future<void> disconnectSignalR() async {
    return await chatDataSourcesImp.disconnectSignalR();
  }

  @override
  Future<void> joinChat(int chatId) async {
    return await chatDataSourcesImp.joinChat(chatId);
  }

  @override
  Future<void> leaveChat(int chatId) async {
    return await chatDataSourcesImp.leaveChat(chatId);
  }

  @override
  void setMessageCallback(Function(MensajeEntity) callback) {
    chatDataSourcesImp.setMessageCallback(callback);
  }
@override
void setOnDisconnectedCallback(VoidCallback callback) {
  chatDataSourcesImp.setOnDisconnectedCallback(callback);
}
  @override
  bool get isSignalRConnected => chatDataSourcesImp.isSignalRConnected;
  
  @override
  Future<void> marcarMensajesLeidos(int chatId, int otroUserId)  async{
    return await chatDataSourcesImp.marcarMensajesLeidos(chatId, otroUserId);
  }
  
  @override
  void onMensajesLeidos(Function(DateTime leidoEn) callback)  {
   return  chatDataSourcesImp.onMensajesLeidos(callback);
  }
  

 
 
}