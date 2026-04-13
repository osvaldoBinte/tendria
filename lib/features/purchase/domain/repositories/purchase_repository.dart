import 'package:tendria/features/purchase/domain/entity/purchase_entity.dart';

abstract class PurchaseRepository {
  Future<void> purchaseApple();
  Future<void> purchaseGoogle();
  Future<List<PurchaseEntity>> getPurchases();
}