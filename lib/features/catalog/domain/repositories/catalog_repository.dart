import 'package:tendria/features/catalog/domain/entities/catalog_entity.dart';

abstract class CatalogRepository {
  Future<List<CatalogEntity>> fetchqualities();
  Future<List<CatalogEntity>> fetchinterests();
}