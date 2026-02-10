import 'package:tendria/features/catalog/domain/repositories/catalog_repository.dart';

class PostQualitiesUsecase {
  final CatalogRepository catalogRepository;

  PostQualitiesUsecase({required this.catalogRepository});

  Future<void> execute(List<int> qualitiesIds) async {
    return await catalogRepository.postQualities(qualitiesIds);
  }
}