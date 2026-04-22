import 'package:tendria/features/purchase/domain/entity/purchase_google_entity.dart';

class PurchaseGoogleModel extends PurchaseGoogleEntity {
  PurchaseGoogleModel({required super.productoId, required super.packageName, required super.purchaseToken});
  factory PurchaseGoogleModel.fromEntity(PurchaseGoogleEntity entity) {
    return PurchaseGoogleModel(productoId: entity.productoId, packageName: entity.packageName, purchaseToken: entity.purchaseToken);
  }
  Map<String, dynamic> toJson(){
    return {
     'productoId':productoId,
     'packageName':packageName,
     'purchaseToken':purchaseToken
    };
  }
}