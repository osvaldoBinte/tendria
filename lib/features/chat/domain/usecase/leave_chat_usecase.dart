 
import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class LeaveChatUsecase {
  final ChatRepository chatRepository;

  LeaveChatUsecase({required this.chatRepository});

  Future<void> execute(int chatId) async {
    return await chatRepository.leaveChat(chatId);
  }
}