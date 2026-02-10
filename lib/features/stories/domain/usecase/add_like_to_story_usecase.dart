import 'package:tendria/features/stories/domain/repository/stories_repository.dart';

class AddLikeToStoryUsecase {
  final StoriesRepository storiesRepository;
  AddLikeToStoryUsecase({required this.storiesRepository});
  Future<void> execute( int historiaId) async {
    return await storiesRepository.addLikeToStory(historiaId);
  }
}