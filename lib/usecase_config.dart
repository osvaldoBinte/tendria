import 'package:tendria/features/auth/data/datasource/auth_data_source_imp.dart';
import 'package:tendria/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:tendria/features/auth/domain/usecase/create_user_usecase.dart';
import 'package:tendria/features/auth/domain/usecase/login_usecase.dart';
import 'package:tendria/features/catalog/data/datasources/catalog_data_sources_imp.dart';
import 'package:tendria/features/catalog/data/repositories/catalog_repository_imp.dart';
import 'package:tendria/features/catalog/domain/usecase/fetch_interests_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/fetch_qualities_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/post_interests_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/post_qualities_usecase.dart';
import 'package:tendria/features/chat/data/datasources/chat_data_sources_imp.dart';
import 'package:tendria/features/chat/data/repositories/chat_repository_imp.dart';
import 'package:tendria/features/chat/domain/usecase/get_chat_mensaje_usecase.dart';
import 'package:tendria/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:tendria/features/like/data/datasources/like_data_sources_imp.dart';
import 'package:tendria/features/like/data/repositories/like_repository_imp.dart';
import 'package:tendria/features/like/domain/usecase/get_like_by_users_usecase.dart';
import 'package:tendria/features/like/domain/usecase/my_match_usecase.dart';
import 'package:tendria/features/like/domain/usecase/toggle_like_usecase.dart';
import 'package:tendria/features/stories/data/datasources/stories_data_sources_imp.dart';
import 'package:tendria/features/stories/data/repository/stories_repository_imp.dart';
import 'package:tendria/features/stories/domain/usecase/add_like_to_story_usecase.dart';
import 'package:tendria/features/stories/domain/usecase/create_strory_usecase.dart';
import 'package:tendria/features/stories/domain/usecase/fetch_stories_by_id_usecase.dart';
import 'package:tendria/features/stories/domain/usecase/fetch_stories_usecase.dart';
import 'package:tendria/features/stories/domain/usecase/remove_story_usecase.dart';
import 'package:tendria/features/stories/domain/usecase/set_story_as_seen_usecase.dart';
import 'package:tendria/features/user/data/datasources/user_data_sources_imp.dart';
import 'package:tendria/features/user/data/repositories/user_repository_imp.dart';
import 'package:tendria/features/user/domain/usecase/fetch_nearby_users_usecase.dart';
import 'package:tendria/features/user/domain/usecase/get_user_usecase.dart';
import 'package:tendria/features/user/domain/usecase/preferences_user_usecase.dart';
import 'package:tendria/features/user/domain/usecase/upload_media_usecase.dart';
import 'package:tendria/features/user/domain/usecase/upload_picture_perfile_usecase.dart';

class UsecaseConfig {
  AuthDataSourceImp? authDataSourceImp;
  CatalogDataSourcesImp? catalogDataSourcesImp;
  UserDataSourcesImp? userDataSourcesImp;
  StoriesDataSourcesImp? storiesDataSourcesImp;
  ChatDataSourcesImp?chatDataSourcesImp;
  LikeDataSourcesImp? likeDataSourcesImp;

  AuthRepositoryImp? authRepositoryImp;
  CatalogRepositoryImp? catalogRepositoryImp;
  UserRepositoryImp? userRepositoryImp;
  StoriesRepositoryImp? storiesRepositoryImp;
  ChatRepositoryImp?chatRepositoryImp;
  LikeRepositoryImp? likeRepositoryImp;

  LoginUsecase? loginUsecase;
  CreateUserUsecase? createUserUsecase;

  FetchInterestsUsecase? fetchInterestsUsecase;
  FetchQualitiesUsecase? fetchQualitiesUsecase;
  PostInterestsUsecase? postInterestsUsecase;
  PostQualitiesUsecase? postQualitiesUsecase;
  
  GetUserUsecase? getUserUsecase;
  FetchNearbyUsersUsecase? fetchNearbyUsersUsecase;
  PreferencesUserUsecase? preferencesUserUsecase;
  UploadMediaUsecase? uploadMediaUsecase;
  UploadPicturePerfileUsecase? uploadPicturePerfileUsecase;
  

 
  GetChatMensajeUsecase?getChatMensajeUsecase;
  SendMessageUsecase?sendMessageUsecase;

   AddLikeToStoryUsecase? addLikeToStoryUsecase;
   CreateStroryUsecase? createStroryUsecase;
   FetchStoriesByIdUsecase? fetchStoriesByIdUsecase;
   FetchStoriesUsecase? fetchStoriesUsecase;
   RemoveStoryUsecase? removeStoryUsecase;
   SetStoryAsSeenUsecase? setStoryAsSeenUsecase;

   GetLikeByUsersUsecase? getLikeByUsersUsecase;
   MyMatchUsecase? myMatchUsecase;
   ToggleLikeUsecase? toggleLikeUsecase;

  
  UsecaseConfig(){
    authDataSourceImp = AuthDataSourceImp();
    userDataSourcesImp = UserDataSourcesImp();
    catalogDataSourcesImp = CatalogDataSourcesImp();
    storiesDataSourcesImp = StoriesDataSourcesImp();
    chatDataSourcesImp = ChatDataSourcesImp();
    likeDataSourcesImp = LikeDataSourcesImp();
    authRepositoryImp = AuthRepositoryImp(authDataSourceImp: authDataSourceImp!);
    catalogRepositoryImp = CatalogRepositoryImp(catalogDataSourcesImp: catalogDataSourcesImp!);
    userRepositoryImp = UserRepositoryImp(userDataSourcesImp: userDataSourcesImp!);
    storiesRepositoryImp = StoriesRepositoryImp(storiesDataSourcesImp: storiesDataSourcesImp!);
    chatRepositoryImp = ChatRepositoryImp(chatDataSourcesImp: chatDataSourcesImp!);
    likeRepositoryImp = LikeRepositoryImp(likeDataSourcesImp: likeDataSourcesImp!);

    loginUsecase = LoginUsecase(authRepository: authRepositoryImp!);
    createUserUsecase = CreateUserUsecase(authRepository: authRepositoryImp!);
    fetchInterestsUsecase = FetchInterestsUsecase(catalogRepository: catalogRepositoryImp!);
    fetchQualitiesUsecase = FetchQualitiesUsecase(catalogRepository: catalogRepositoryImp!);
    getUserUsecase = GetUserUsecase(userRepository: userRepositoryImp!);
    fetchNearbyUsersUsecase = FetchNearbyUsersUsecase(userRepository: userRepositoryImp!);
    postInterestsUsecase = PostInterestsUsecase(catalogRepository: catalogRepositoryImp!);
    postQualitiesUsecase = PostQualitiesUsecase(catalogRepository: catalogRepositoryImp!);
    preferencesUserUsecase = PreferencesUserUsecase(userRepository: userRepositoryImp!);
    uploadMediaUsecase = UploadMediaUsecase(userRepository: userRepositoryImp!);
    uploadPicturePerfileUsecase = UploadPicturePerfileUsecase(userRepository: userRepositoryImp!);
    addLikeToStoryUsecase = AddLikeToStoryUsecase(storiesRepository: storiesRepositoryImp!);
    createStroryUsecase = CreateStroryUsecase(storiesRepository: storiesRepositoryImp!);
    fetchStoriesByIdUsecase = FetchStoriesByIdUsecase(storiesRepository: storiesRepositoryImp!);
    fetchStoriesUsecase = FetchStoriesUsecase(storiesRepository: storiesRepositoryImp!);
    removeStoryUsecase = RemoveStoryUsecase(storiesRepository: storiesRepositoryImp!);
    setStoryAsSeenUsecase = SetStoryAsSeenUsecase(storiesRepository: storiesRepositoryImp!);
    getChatMensajeUsecase = GetChatMensajeUsecase(chatRepository: chatRepositoryImp!);
    sendMessageUsecase = SendMessageUsecase(chatRepository: chatRepositoryImp!);
    getLikeByUsersUsecase = GetLikeByUsersUsecase(likeRepository: likeRepositoryImp!);
    myMatchUsecase = MyMatchUsecase(likeRepository: likeRepositoryImp!);
    toggleLikeUsecase = ToggleLikeUsecase(likeRepository: likeRepositoryImp!);
  }
}