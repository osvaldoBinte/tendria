import 'package:tendria/features/purchase/domain/entity/purchase_apple_entity.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_entity.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_google_entity.dart';

abstract class PurchaseRepository {
  Future<void> purchaseApple(PurchaseAppleEntity entity);
  Future<void> purchaseGoogle(PurchaseGoogleEntity entity);
  Future<List<PurchaseEntity>> getPurchases();
}