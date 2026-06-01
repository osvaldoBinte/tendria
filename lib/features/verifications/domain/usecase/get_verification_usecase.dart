import 'package:tendria/features/verifications/data/repositories/verifications_repository_imp.dart';
import 'package:tendria/features/verifications/domain/entities/get_verification_entity.dart';

class GetVerificationUsecase {
  final VerificationsRepositoryImp verificationsRepository;
  GetVerificationUsecase({required this.verificationsRepository});
  Future<List<GetVerificationEntity>> call() async {
    return await verificationsRepository.getVerifications();
  }
}