import 'package:tendria/features/facebookEvent/domain/repositories/facebook_repository.dart';

class LogLoginUsecase {
  final FacebookRepository facebookRepository;

  LogLoginUsecase({required this.facebookRepository});
  Future<void> call({required String method}) async {
    await facebookRepository.logLogin(method: method);
  }
}