import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/features/unlock/data/datasources/unlock_datasources_imp.dart';
import 'package:tendria/features/unlock/domain/entities/unlock_entity.dart';
import 'package:tendria/features/unlock/domain/repositories/unlock_repository.dart';

class UnlockRepositoryImp extends UnlockRepository {
  final UnlockDatasourcesImp unlockDatasourcesImp;
   AuthService authService =AuthService();

  UnlockRepositoryImp({required this.unlockDatasourcesImp});

  @override
  Future<void> blockUser(int iduser) async {
    final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return unlockDatasourcesImp.blockUser(iduser, token);
  }

  @override
  Future<List<UnlockEntity>> fetchBlockedUsers() async {
    final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return unlockDatasourcesImp.fetchBlockedUsers(token);
  }

  @override
  Future<void> unblockUser(int iduser) async {
    final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return unlockDatasourcesImp.unblockUser(iduser, token);
  }

}