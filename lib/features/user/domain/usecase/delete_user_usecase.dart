import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class DeleteUserUsecase {
  final UserRepository userRepository;
  DeleteUserUsecase({required this.userRepository});
  Future<void> execute() async {
    return await userRepository.deleteUser();
  }
}