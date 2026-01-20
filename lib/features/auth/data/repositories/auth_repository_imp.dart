import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/features/auth/data/datasource/auth_data_source_imp.dart';
import 'package:tendria/features/auth/domain/entities/response/login_response_entity.dart';
import 'package:tendria/features/auth/domain/entities/user/create_user_entity.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/auth/domain/repositories/auth_repository.dart';
import 'dart:async';

class AuthRepositoryImp extends AuthRepository {
  final AuthDataSourceImp authDataSourceImp;
  AuthRepositoryImp({required this.authDataSourceImp});
      String defaultApiServer = AppConstants.serverBase;

  @override
  Future<LoginResponseEntity> login(String email, String password) async {
    return await authDataSourceImp.login(email, password);
  }

  @override
  Future<void> createUser(CreateUserEntity entity) async  {
    return await authDataSourceImp.createuser(entity);
  }

 

}