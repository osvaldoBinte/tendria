import 'package:tendria/features/purchase/domain/entity/purchase_entity.dart';

class PurchaseModel extends PurchaseEntity {
  PurchaseModel({required super.ordenId, required super.productId,  super.name,  super.credits,  super.descripcion,  super.price});

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      ordenId: json['orden'],
      productId: json['productoId'],
      name: json['nombre'],
      credits: json['creditos'],
      descripcion: json['descripcion'],
      price: json['precioMxn'],
    );
  }
}