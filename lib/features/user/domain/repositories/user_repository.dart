import 'package:tendria/features/user/domain/entities/update_user_entity.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/entities/preferences_entity.dart';
import 'package:tendria/features/user/domain/entities/upload_media_entity.dart';

abstract class UserRepository {
    Future<GetUserEntity> fetchUser();
    Future<List<GetUserEntity>> fetchNearbyUsers(int pageNumber,int pageSize,);
    Future<void> preferencesUser(PreferencesEntity entity);
    Future<void> putpreferencesUser(PreferencesEntity entity);
    Future<void> uploadMedia(List<UploadMediaEntity> entities);
    Future<void> uploadPicturePerfile(String file);
    Future<GetUserEntity> getuserbyid(int iduser);
    Future<void> updateUser(UpdateUserEntity entity);

    Future<void> deleteMedia(int mediaId);
    Future<void> deleteUser();
}