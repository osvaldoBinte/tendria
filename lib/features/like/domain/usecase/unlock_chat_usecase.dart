import 'package:tendria/features/like/domain/repositories/like_repository.dart';

class UnlockChatUsecase {
  final LikeRepository likeRepository;

  UnlockChatUsecase({required this.likeRepository});

  Future<void> execute(int chatId) async {
    return likeRepository.unlockChat(chatId);
  }
}