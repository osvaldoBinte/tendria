import 'package:tendria/features/like/domain/entities/matches_entity.dart';
import 'package:tendria/features/like/domain/repositories/like_repository.dart';

class MyMatchUsecase {
  final LikeRepository likeRepository;
  MyMatchUsecase({required this.likeRepository});
  Future<List<MatchesEntity>> execute() async {
    return await likeRepository.myMatch();
  }
}