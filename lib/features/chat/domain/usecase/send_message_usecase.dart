import 'package:tendria/features/chat/domain/entities/post_chat_entity.dart';
import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUsecase {
  final ChatRepository chatRepository;
  SendMessageUsecase({required this.chatRepository});
  Future<void> execute(PostChatEntity entity) async {
    return await chatRepository.postchat(entity);
  }
}