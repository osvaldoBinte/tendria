import 'package:tendria/features/catalog/domain/entities/catalog_entity.dart';

class CatalogModel extends CatalogEntity {
  CatalogModel({required super.id, required super.name});

  factory CatalogModel.fromJson(Map<String, dynamic> json) {
    return CatalogModel(id: json['id'], name: json['nombre']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': name};
  }
}
