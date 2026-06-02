import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/features/user/domain/entities/create_reports_user_entity.dart';
import 'package:tendria/features/user/domain/entities/update_location_entity.dart';
import 'package:tendria/features/user/domain/entities/update_user_entity.dart';
import 'package:tendria/features/user/data/datasources/user_data_sources_imp.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/entities/preferences_entity.dart';
import 'package:tendria/features/user/domain/entities/upload_media_entity.dart';
import 'package:tendria/features/user/domain/entities/user_balance_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImp extends UserRepository {
  final UserDataSourcesImp userDataSourcesImp;
  AuthService authService = AuthService();
  UserRepositoryImp({required this.userDataSourcesImp});
  @override
  Future<GetUserEntity> fetchUser() async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.getuser(token);
  }

  @override
  Future<void> preferencesUser(PreferencesEntity entity) async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.preferencesUser(entity, token);
  }

  @override
  Future<void> uploadMedia(List<UploadMediaEntity> entities) async {
      final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
      return await userDataSourcesImp.createMedia(entities, token);
  }
  
  @override
  Future<List<GetUserEntity>> fetchNearbyUsers(int pageNumber,int pageSize,) async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.getNearbyUsers(pageNumber,pageSize,token);
  }
  
  @override
  Future<void> uploadPicturePerfile(String file) async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.uploadPicturePerfil(file, token);
  }
  
  @override
  Future<GetUserEntity> getuserbyid(int iduser) async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.getuserbyid(iduser, token);
  }

  @override
  Future<void> updateUser(UpdateUserEntity entity) async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.updateuser(entity, token);
  }
  
  @override
  Future<void> putpreferencesUser(PreferencesEntity entity)  async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.putpreferencesUser(entity, token);
  }
  
  @override
  Future<void> deleteMedia(int mediaId) async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.deleteMedia(mediaId, token);
  }
  
  @override
  Future<void> deleteUser()  async {
        final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
 return await userDataSourcesImp.deleteUser(token);
  }

  @override
  Future<void> updateLocation(UpdateLocationEntity entity)  async{
        final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
  return await userDataSourcesImp.updateLocation(entity, token);
  }

  @override
  Future<UserBalanceEntity> getuserbalance() async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.getuserbalance(token);
  }

  @override
  Future<void> createReportsUser(CreateReportsUserEntity entity) async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.createReportsUser(entity, token);
  }
  
  @override
  Future<List<UpdateLocationEntity>> searchcity(String city) async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.searchcity(city, token);
  }
  
  @override
  Future<void> deactivateTrip() async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.deactivateTrip(token);
  }
  
  @override
  Future<void> updateCity(UpdateLocationEntity entity) async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await userDataSourcesImp.updateCity(entity, token);
  }
}
