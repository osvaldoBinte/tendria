import 'package:tendria/features/stories/domain/repository/stories_repository.dart';

class RemoveStoryUsecase {
  final StoriesRepository storiesRepository;
  RemoveStoryUsecase({required this.storiesRepository});
  Future<void> execute(int historiaId) async { 
    return storiesRepository.removeStory(historiaId);
  }
}