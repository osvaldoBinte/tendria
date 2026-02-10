import 'package:tendria/features/stories/domain/entities/getstories/get_stories_entity.dart';
import 'package:tendria/features/stories/domain/entities/getstories/story_entity.dart';
import 'package:tendria/features/stories/domain/entities/post/post_stories_entity.dart';

abstract class StoriesRepository {
  Future<List <GetStoriesEntity>> fetchStories();
  Future<List<StoryEntity>> fetchStoriesbyid(int iduser);
  Future<void> createStrory(PostStoriesEntity entity);
  Future<void> addLikeToStory(int id);
  Future<void> setStoryAsSeen(int id);
  Future<void> removeStory(int id);
}
