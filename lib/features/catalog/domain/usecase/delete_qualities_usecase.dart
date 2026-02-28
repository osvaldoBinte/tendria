import 'package:tendria/features/catalog/domain/repositories/catalog_repository.dart';

class DeleteQualitiesUsecase {
  final CatalogRepository catalogRepository;

  DeleteQualitiesUsecase({required this.catalogRepository});

  Future<void> execute(List<int> qualitiesIds) async {
    await catalogRepository.deletequalities(qualitiesIds);
  }
}