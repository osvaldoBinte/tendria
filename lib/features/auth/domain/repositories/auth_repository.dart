import 'package:tendria/features/auth/domain/entities/response/login_response_entity.dart';
import 'package:tendria/features/auth/domain/entities/user/create_user_entity.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';

abstract class AuthRepository {
  Future<LoginResponseEntity> login(String email,String password);
  Future<void> createUser(CreateUserEntity entity);

}