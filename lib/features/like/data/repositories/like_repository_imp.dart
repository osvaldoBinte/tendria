import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/features/like/data/datasources/like_data_sources_imp.dart';
import 'package:tendria/features/like/domain/entities/liked_by_users_entity.dart';
import 'package:tendria/features/like/domain/entities/matches_entity.dart';
import 'package:tendria/features/like/domain/repositories/like_repository.dart';

class LikeRepositoryImp  implements LikeRepository{
  final LikeDataSourcesImp likeDataSourcesImp;
  AuthService authService = AuthService();
  LikeRepositoryImp({required this.likeDataSourcesImp});

  @override
  Future<List<LikedByUsersEntity>> getLikedByUsers(int postId) async {
        final token = await authService.getToken() ?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));

    return likeDataSourcesImp.getLikedByUsers(postId, token);
  }

  @override
  Future<List<MatchesEntity>> myMatch() async {
    final token = await authService.getToken() ?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));

    return likeDataSourcesImp.myMatch(token);
  }

  @override
  Future<void> toggleLike(int userId, bool liked) async {
    final token = await authService.getToken() ?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));

    return likeDataSourcesImp.toggleLike(userId, liked, token);
  }
}