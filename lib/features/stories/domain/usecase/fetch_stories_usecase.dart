import 'package:tendria/features/stories/domain/entities/getstories/get_stories_entity.dart';
import 'package:tendria/features/stories/domain/repository/stories_repository.dart';

class FetchStoriesUsecase {
  final StoriesRepository storiesRepository;
  FetchStoriesUsecase({required this.storiesRepository});
  Future<List <GetStoriesEntity>> execute() async {
    return await storiesRepository.fetchStories();
  }
}