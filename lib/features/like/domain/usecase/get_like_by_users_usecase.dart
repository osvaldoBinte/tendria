import 'package:tendria/features/like/domain/entities/liked_by_users_entity.dart';
import 'package:tendria/features/like/domain/repositories/like_repository.dart';

class GetLikeByUsersUsecase {
  final LikeRepository likeRepository;
  GetLikeByUsersUsecase({required this.likeRepository});
  Future<List<LikedByUsersEntity>> execute(int postId) async {
    return await likeRepository.getLikedByUsers(postId);
  }
}