import 'package:tendria/features/user/domain/entities/update_user_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class UpdateUserUsecase {
  final UserRepository userRepository;
  UpdateUserUsecase({required this.userRepository});
  Future<void> execute(UpdateUserEntity entity) async {
    await userRepository.updateUser(entity);
  }
}