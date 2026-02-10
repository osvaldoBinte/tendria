import 'package:tendria/features/stories/domain/repository/stories_repository.dart';

class SetStoryAsSeenUsecase {
  final StoriesRepository storiesRepository;
  SetStoryAsSeenUsecase({required this.storiesRepository});
  Future<void> execute(int historiaId) async {
    return storiesRepository.setStoryAsSeen(historiaId);
  }
}