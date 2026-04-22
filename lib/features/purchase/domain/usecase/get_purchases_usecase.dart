import 'package:tendria/features/purchase/domain/entity/purchase_entity.dart';
import 'package:tendria/features/purchase/domain/repositories/purchase_repository.dart';

class GetPurchasesUsecase {
  final PurchaseRepository purchaseRepository;
  GetPurchasesUsecase({required this.purchaseRepository});
  Future<List<PurchaseEntity>> call() async {
    return await purchaseRepository.getPurchases();
  }
}