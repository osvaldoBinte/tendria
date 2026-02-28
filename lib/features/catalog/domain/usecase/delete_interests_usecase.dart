import 'package:tendria/features/catalog/domain/repositories/catalog_repository.dart';

class DeleteInterestsUsecase {
  final CatalogRepository catalogRepository;

  DeleteInterestsUsecase({required this.catalogRepository});

  Future<void> execute(List<int> interestsIds) async {
    await catalogRepository.deleteinterests(interestsIds);
  }
}