import 'package:tendria/features/purchase/domain/entity/purchase_apple_entity.dart';

class PurchaseAppleModel extends PurchaseAppleEntity{
  PurchaseAppleModel({required super.productoId, required super.receiptData});

  factory PurchaseAppleModel.fromEntity(PurchaseAppleEntity entity) {
    return PurchaseAppleModel(productoId: entity.productoId, receiptData:  entity.receiptData);
  }
  Map<String, dynamic> toJson() {
    return {
      'productoId':productoId,
      'receiptData':receiptData
    };
  }
}