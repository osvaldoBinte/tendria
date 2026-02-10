import 'package:tendria/features/stories/domain/entities/getstories/story_entity.dart';
import 'package:tendria/features/stories/domain/repository/stories_repository.dart';

class FetchStoriesByIdUsecase {
  final StoriesRepository storiesRepository;
  FetchStoriesByIdUsecase({required this.storiesRepository});
  Future<List<StoryEntity>>  execute(int iduser) async {
    return await storiesRepository.fetchStoriesbyid(iduser);
  }
}