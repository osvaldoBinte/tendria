import 'package:tendria/features/like/domain/repositories/like_repository.dart';

class ToggleLikeUsecase {
  final LikeRepository likeRepository;
  ToggleLikeUsecase({required this.likeRepository});
  Future<void> execute(int userId, bool liked) async {
    return await likeRepository.toggleLike(userId, liked);
  }
}