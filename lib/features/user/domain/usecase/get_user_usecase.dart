import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class GetUserUsecase {
  final UserRepository userRepository;

  GetUserUsecase({required this.userRepository});

  Future<GetUserEntity> call() async {
    return await userRepository.fetchUser();
  }
}