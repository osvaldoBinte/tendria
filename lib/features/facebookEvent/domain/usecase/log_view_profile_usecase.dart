import 'package:tendria/features/facebookEvent/domain/repositories/facebook_repository.dart';

class LogViewProfileUsecase {
  final FacebookRepository facebookRepository;

  LogViewProfileUsecase({required this.facebookRepository});
  Future<void> call({required String targetUserId}) async {
    await facebookRepository.logViewProfile(targetUserId: targetUserId);
  }
}