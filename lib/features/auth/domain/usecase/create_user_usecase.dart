import 'package:tendria/features/auth/domain/entities/user/create_user_entity.dart';
import 'package:tendria/features/auth/domain/repositories/auth_repository.dart';

class CreateUserUsecase {
  final AuthRepository authRepository;
  CreateUserUsecase({required this.authRepository});
  Future<void> execute(CreateUserEntity entity) async {
    return await authRepository.createUser(entity);
  }
}