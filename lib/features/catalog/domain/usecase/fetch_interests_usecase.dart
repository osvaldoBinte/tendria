import 'package:tendria/features/catalog/domain/entities/catalog_entity.dart';
import 'package:tendria/features/catalog/domain/repositories/catalog_repository.dart';

class FetchInterestsUsecase {
  final CatalogRepository catalogRepository;
  FetchInterestsUsecase({required this.catalogRepository});
  Future<List<CatalogEntity>> execute() async {
    return await catalogRepository.fetchinterests();
  }
}