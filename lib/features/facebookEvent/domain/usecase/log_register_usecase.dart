import 'package:tendria/features/facebookEvent/domain/repositories/facebook_repository.dart';

class LogRegisterUsecase {
  final FacebookRepository facebookRepository;

  LogRegisterUsecase({required this.facebookRepository});
  Future<void> call({required String method}) async {
    await facebookRepository.logRegister(method: method);
  }
}