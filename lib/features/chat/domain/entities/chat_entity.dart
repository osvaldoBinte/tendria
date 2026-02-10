import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/domain/entities/usuario_chat_entity.dart';

class ChatEntity {
  final int chatId;
  final UsuarioChatEntity otroUsuario;
  final List<MensajeEntity> mensajes;

  ChatEntity({
    required this.chatId,
    required this.otroUsuario,
    required this.mensajes,
  });
}
