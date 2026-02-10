import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/features/stories/data/datasources/stories_data_sources_imp.dart';
import 'package:tendria/features/stories/domain/entities/getstories/get_stories_entity.dart';
import 'package:tendria/features/stories/domain/entities/getstories/story_entity.dart';
import 'package:tendria/features/stories/domain/entities/post/post_stories_entity.dart';
import 'package:tendria/features/stories/domain/repository/stories_repository.dart';

class StoriesRepositoryImp implements StoriesRepository {
  final StoriesDataSourcesImp storiesDataSourcesImp;
  AuthService authService = AuthService();
  StoriesRepositoryImp({required this.storiesDataSourcesImp});

  @override
  Future<void> addLikeToStory(int id) async {
    final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await storiesDataSourcesImp.addLikeToStory(id,token);
  }

  @override
  Future<void> createStrory(PostStoriesEntity entity) async {
    final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await storiesDataSourcesImp.createStrory(entity,token);
  }

  @override
  Future<List< GetStoriesEntity>> fetchStories() async {
    final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await storiesDataSourcesImp.fetchStories(token);
  }

  @override
  Future<List<StoryEntity>>  fetchStoriesbyid(int iduser) async {
    final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await storiesDataSourcesImp.fetchStoriesbyid(iduser,token);
  }

  @override
  Future<void> removeStory(int id) async {
    final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await storiesDataSourcesImp.removeStory(id,token);
  }

  @override
  Future<void> setStoryAsSeen(int id) async {
    final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await storiesDataSourcesImp.setStoryAsSeen(id,token);
  }
}