import 'package:tendria/features/purchase/domain/entity/validate_coupons_entity.dart';
import 'package:tendria/features/purchase/domain/repositories/purchase_repository.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class ValidateCouponsUsecase {
  final PurchaseRepository purchaseRepository;
  ValidateCouponsUsecase({required this.purchaseRepository});

  Future<ValidateCouponsEntity> execute(String couponCode, int userId,num? creditsToBuy) async {
    return await purchaseRepository.validateCoupons(couponCode, userId, creditsToBuy);
  }
}