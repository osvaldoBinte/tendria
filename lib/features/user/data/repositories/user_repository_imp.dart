import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/features/user/data/datasources/user_data_sources_imp.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImp extends UserRepository {
  final UserDataSourcesImp userDataSourcesImp;
  AuthService authService = AuthService();
  UserRepositoryImp({required this.userDataSourcesImp});
  @override
  Future<GetUserEntity> fetchUser() async {
   final token = await authService.getToken() ??( throw Exception("No hay sesión activa. El usuario debe iniciar sesión."));
   return await userDataSourcesImp.getuser(token);
  }
}