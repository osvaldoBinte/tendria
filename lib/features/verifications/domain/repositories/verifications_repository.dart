import 'package:tendria/features/verifications/domain/entities/get_verification_entity.dart';
import 'package:tendria/features/verifications/domain/entities/verification_selfie_entity.dart';
import 'package:tendria/features/verifications/domain/entities/verifications_entity.dart';

abstract class VerificationsRepository {
  Future<void> verification(VerificationsEntity verification);
  Future<void> verificationselfie(VerificationSelfieEntity entity);
  Future<List<GetVerificationEntity>> getVerifications();
}
