import 'package:tendria/features/stories/domain/entities/post/post_stories_entity.dart';
import 'package:tendria/features/stories/domain/repository/stories_repository.dart';

class CreateStroryUsecase {
  final StoriesRepository storiesRepository;
  CreateStroryUsecase({required this.storiesRepository});
  Future<void> execute(PostStoriesEntity entity) async {
    return await storiesRepository.createStrory(entity);
  }
}