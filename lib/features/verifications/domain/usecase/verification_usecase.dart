import 'package:tendria/features/verifications/domain/entities/verifications_entity.dart';
import 'package:tendria/features/verifications/domain/repositories/verifications_repository.dart';

class VerificationUsecase {
  final VerificationsRepository verificationsRepository;
  VerificationUsecase({required this.verificationsRepository});
  Future<void> call(VerificationsEntity verification) async {
    return await verificationsRepository.verification(verification);
  }
}