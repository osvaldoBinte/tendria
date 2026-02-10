// lib/features/chat/domain/usecase/setup_message_listener_usecase.dart

import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class SetupMessageListenerUsecase {
  final ChatRepository repository;

  SetupMessageListenerUsecase({required this.repository});

  void execute(Function(MensajeEntity) onMessageReceived) {
    repository.setMessageCallback(onMessageReceived);
  }
}