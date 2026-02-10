import 'package:tendria/features/chat/data/model/mensaje_model.dart';
import 'package:tendria/features/chat/data/model/usuario_chat_model.dart';
import 'package:tendria/features/chat/domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  ChatModel({
    required super.chatId,
    required super.otroUsuario,
    required super.mensajes,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chatId'],
      otroUsuario: UsuarioChatModel.fromJson(json['otroUsuario']),
      mensajes: (json['mensajes'] as List)
          .map((e) => MensajeModel.fromJson(e))
          .toList(),
    );
  }
}
