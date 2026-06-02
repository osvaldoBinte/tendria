import 'package:tendria/features/user/domain/entities/create_reports_user_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class CreateReportsUserUsecase {
  final UserRepository userRepository;
  CreateReportsUserUsecase({required this.userRepository});
  Future<void> execute(CreateReportsUserEntity entity) async {
    return await userRepository.createReportsUser(entity);
  }
}