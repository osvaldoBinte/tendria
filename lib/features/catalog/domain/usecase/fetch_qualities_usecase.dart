import 'package:tendria/features/catalog/domain/entities/catalog_entity.dart';
import 'package:tendria/features/catalog/domain/repositories/catalog_repository.dart';

class FetchQualitiesUsecase {
  final CatalogRepository catalogRepository;
  FetchQualitiesUsecase({required this.catalogRepository});
  Future<List<CatalogEntity>> execute() async {
    return await catalogRepository.fetchqualities();
  }
}