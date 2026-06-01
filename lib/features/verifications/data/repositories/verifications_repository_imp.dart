import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/features/verifications/data/datasources/verifications_data_sources_imp.dart';
import 'package:tendria/features/verifications/domain/entities/get_verification_entity.dart';
import 'package:tendria/features/verifications/domain/entities/verification_selfie_entity.dart';
import 'package:tendria/features/verifications/domain/entities/verifications_entity.dart';
import 'package:tendria/features/verifications/domain/repositories/verifications_repository.dart';

class VerificationsRepositoryImp implements VerificationsRepository {
  final VerificationsDataSourcesImp verificationsDataSourcesImp;
    AuthService authService = AuthService();

  VerificationsRepositoryImp({required this.verificationsDataSourcesImp});

  @override
  Future<void> verification(VerificationsEntity verification) async {
        final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await verificationsDataSourcesImp.verification(verification, token);
  }

  @override
  Future<void> verificationselfie(VerificationSelfieEntity entity) async {
      final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await verificationsDataSourcesImp.verificationselfie(entity, token);
    
  }

  @override
  Future<List<GetVerificationEntity>> getVerifications() async {
      final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await verificationsDataSourcesImp.getVerifications(token);
 
  }
}
