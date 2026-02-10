import 'package:tendria/features/chat/domain/entities/chat_entity.dart';
import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class GetChatMensajeUsecase {
  final ChatRepository chatRepository;
  GetChatMensajeUsecase({required this.chatRepository});
  Future<ChatEntity> execute(int chatid) async {
    return chatRepository.chatmensaje(chatid);
  }
  
}