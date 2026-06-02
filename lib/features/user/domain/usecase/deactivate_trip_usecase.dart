import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class DeactivateTripUsecase {
  final UserRepository userRepository;

  DeactivateTripUsecase({required this.userRepository});

  Future<void> execute() async {
    await userRepository.deactivateTrip();
  }
}