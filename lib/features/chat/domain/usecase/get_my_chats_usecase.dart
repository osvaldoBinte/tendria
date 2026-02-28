import 'package:tendria/features/chat/domain/entities/chat_entity.dart';
import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class GetMyChatsUsecase {
  final ChatRepository chatRepository;

  GetMyChatsUsecase({required this.chatRepository});

  Future<List<ChatEntity>> execute() async{
    return await chatRepository.getMyChats();
  }
}