 import 'package:flutter/material.dart';
import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class SetOnDisconnectedCallbackUsecase {
  final ChatRepository chatRepository;
  SetOnDisconnectedCallbackUsecase({required this.chatRepository});

  void execute(VoidCallback callback) {
    chatRepository.setOnDisconnectedCallback(callback);
  }
}