import 'package:tendria/features/purchase/domain/entity/purchase_google_entity.dart';
import 'package:tendria/features/purchase/domain/repositories/purchase_repository.dart';

class PurchaseGoogleUsecase {
  final PurchaseRepository purchaseRepository;
  PurchaseGoogleUsecase({required this.purchaseRepository});
  Future<void> call(PurchaseGoogleEntity entity) async {
    return await purchaseRepository.purchaseGoogle(entity);
  } 
}