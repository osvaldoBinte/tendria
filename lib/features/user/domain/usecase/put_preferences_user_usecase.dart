import 'package:tendria/features/user/domain/entities/preferences_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class PutPreferencesUserUsecase {
  final UserRepository userRepository;

  PutPreferencesUserUsecase({required this.userRepository});

  Future<void> execute(PreferencesEntity entity) async {
    return await userRepository.putpreferencesUser(entity);
  }
}