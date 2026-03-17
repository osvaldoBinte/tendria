import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class OnMensajesLeidosUsecase {
  final ChatRepository chatRepository;
  OnMensajesLeidosUsecase({required this.chatRepository});

  void execute(Function(DateTime leidoEn) onLeido) {
    chatRepository.onMensajesLeidos(onLeido);
  }
}