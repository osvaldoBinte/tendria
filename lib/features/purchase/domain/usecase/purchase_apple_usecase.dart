import 'package:tendria/features/purchase/domain/entity/purchase_apple_entity.dart';
import 'package:tendria/features/purchase/domain/repositories/purchase_repository.dart';

class PurchaseAppleUsecase {
  final PurchaseRepository purchaseRepository;
  PurchaseAppleUsecase({required this.purchaseRepository});
  Future<void> call(PurchaseAppleEntity entity) async {
    return await purchaseRepository.purchaseApple(entity);
  }
}