import 'package:tendria/features/catalog/domain/repositories/catalog_repository.dart';

class PostInterestsUsecase {
  final CatalogRepository catalogRepository;

  PostInterestsUsecase({required this.catalogRepository});

  Future<void> execute(List<int> interestsIds) async {
    return await catalogRepository.postInterests(interestsIds);
  }
}