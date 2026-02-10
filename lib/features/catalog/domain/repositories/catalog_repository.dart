import 'package:tendria/features/catalog/domain/entities/catalog_entity.dart';

abstract class CatalogRepository {
  Future<List<CatalogEntity>> fetchqualities();
  Future<List<CatalogEntity>> fetchinterests();
  Future<void> postInterests(List<int> interestsIds);
  Future<void> postQualities(List<int> qualitiesIds);
}