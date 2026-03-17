import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class MarcarMensajesLeidosUsecase {
  final ChatRepository chatRepository;
  MarcarMensajesLeidosUsecase({required this.chatRepository});

  Future<void> execute(int chatId, int otroUserId) async {
    await chatRepository.marcarMensajesLeidos(chatId, otroUserId);
  }
}