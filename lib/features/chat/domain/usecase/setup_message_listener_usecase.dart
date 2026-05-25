 
import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class SetupMessageListenerUsecase {
  final ChatRepository chatRepository;

  SetupMessageListenerUsecase({required this.chatRepository});

  void execute(Function(MensajeEntity) onMessageReceived) {
    chatRepository.setMessageCallback(onMessageReceived);
  }
}