import 'package:tendria/features/facebookEvent/domain/repositories/facebook_repository.dart';

class LogMatchUsecase {
  final FacebookRepository facebookRepository;

  LogMatchUsecase({required this.facebookRepository});
  Future<void> call({required String targetUserId}) async {
    await facebookRepository.logMatch(targetUserId: targetUserId);
  }
}