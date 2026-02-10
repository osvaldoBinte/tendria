// lib/features/chat/domain/usecase/leave_chat_usecase.dart

import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class LeaveChatUsecase {
  final ChatRepository repository;

  LeaveChatUsecase({required this.repository});

  Future<void> execute(int chatId) async {
    return await repository.leaveChat(chatId);
  }
}