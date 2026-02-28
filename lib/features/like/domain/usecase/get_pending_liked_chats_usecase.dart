import 'package:tendria/features/like/domain/entities/pending_chat_entity.dart';
import 'package:tendria/features/like/domain/repositories/like_repository.dart';

class GetPendingLikedChatsUsecase {
  final LikeRepository likeRepository;
  GetPendingLikedChatsUsecase({required this.likeRepository});
  Future<List<PendingChatEntity>> execute() async {
    return await likeRepository.getPendingLikedChats();
  }
}