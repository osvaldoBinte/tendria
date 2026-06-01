import 'package:tendria/features/verifications/domain/entities/verification_selfie_entity.dart';
import 'package:tendria/features/verifications/domain/repositories/verifications_repository.dart';

class VerificationSelfieUsecase {
  final VerificationsRepository verificationsRepository;
  VerificationSelfieUsecase({required this.verificationsRepository}); 
  Future<void> call(VerificationSelfieEntity entity) async {
    return await verificationsRepository.verificationselfie(entity);
  }
}