 

import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class JoinChatUsecase {
  final ChatRepository chatRepository;

  JoinChatUsecase({required this.chatRepository});

  Future<void> execute(int chatId) async {
    return await chatRepository.joinChat(chatId);
  }
}