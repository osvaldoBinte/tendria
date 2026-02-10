import 'package:tendria/features/like/domain/entities/liked_by_users_entity.dart';
import 'package:tendria/features/like/domain/entities/matches_entity.dart';

abstract class LikeRepository {
  Future<List<LikedByUsersEntity>> getLikedByUsers(int postId);
  Future<void> toggleLike(int userId, bool liked);
  Future<List<MatchesEntity>> myMatch();
}