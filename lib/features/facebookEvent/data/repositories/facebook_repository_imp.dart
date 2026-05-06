import 'package:tendria/features/facebookEvent/data/datasources/facebook_datasources_imp.dart';
import 'package:tendria/features/facebookEvent/domain/repositories/facebook_repository.dart';

class FacebookRepositoryImpl implements FacebookRepository {
  final FacebookDatasourcesImp facebookDatasourcesImp;

  FacebookRepositoryImpl({required this.facebookDatasourcesImp});

  @override
  Future<void> logRegister({required String method}) async {
    await facebookDatasourcesImp.logRegister(method: method);
  }

  @override
  Future<void> logLogin({required String method}) async {
    await facebookDatasourcesImp.logLogin(method: method);
  }

  @override
  Future<void> logMatch({required String targetUserId}) async {
    await facebookDatasourcesImp.logMatch(targetUserId: targetUserId);
  }

  @override
  Future<void> logViewProfile({required String targetUserId}) async {
    await facebookDatasourcesImp.logViewProfile(targetUserId: targetUserId);
  }
}