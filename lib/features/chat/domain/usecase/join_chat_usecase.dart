// lib/features/chat/domain/usecase/join_chat_usecase.dart

import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class JoinChatUsecase {
  final ChatRepository repository;

  JoinChatUsecase({required this.repository});

  Future<void> execute(int chatId) async {
    return await repository.joinChat(chatId);
  }
}