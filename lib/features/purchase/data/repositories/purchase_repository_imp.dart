import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/features/purchase/data/datasources/purchase_data_sources_imp.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_apple_entity.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_entity.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_google_entity.dart';
import 'package:tendria/features/purchase/domain/entity/validate_coupons_entity.dart';
import 'package:tendria/features/purchase/domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImp  extends PurchaseRepository {
  final PurchaseDataSourcesImp purchaseDataSourcesImp;
  AuthService authService = AuthService();
  PurchaseRepositoryImp({required this.purchaseDataSourcesImp});

  @override
  Future<List<PurchaseEntity>> getPurchases() async {
    final token = await authService.getToken() ?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));

    return await purchaseDataSourcesImp.getPurchases(token);
  }

  @override
  Future<void> purchaseApple(PurchaseAppleEntity entity) async {
        final token = await authService.getToken() ?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await purchaseDataSourcesImp.purchaseApple(entity, token);
  }

  @override
  Future<void> purchaseGoogle(PurchaseGoogleEntity entity) async {
       final token = await authService.getToken() ?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
       return await purchaseDataSourcesImp.purchaseGoogle(entity, token);

  }
    @override
  Future<ValidateCouponsEntity> validateCoupons(String couponCode, int userId,num? creditsToBuy) async {
    final token = await authService.getToken() ?? (throw Exception("No hay sesión activa. El usuario debe iniciar sesión.",));
    return await purchaseDataSourcesImp.validateCoupons(couponCode, userId, creditsToBuy, token);
  }
}