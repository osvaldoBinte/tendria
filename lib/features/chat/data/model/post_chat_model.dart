import 'package:tendria/features/chat/domain/entities/post_chat_entity.dart';

class PostChatModel extends PostChatEntity {
  PostChatModel({required super.chatId, required super.menssage});

  factory PostChatModel.fromEntity(PostChatEntity entity) {
    return PostChatModel(chatId: entity.chatId, menssage: entity.menssage);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'chatId':chatId,
      'mensaje' : menssage
    };
  }
  Map<String, dynamic> toJsonfirstMessage() {
    return {
      'toUserId':chatId,
      'primerMensaje' : menssage
    };
  }
}
