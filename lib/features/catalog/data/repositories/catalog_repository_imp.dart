import 'package:tendria/features/catalog/data/datasources/catalog_data_sources_imp.dart';
import 'package:tendria/features/catalog/domain/entities/catalog_entity.dart';
import 'package:tendria/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImp extends CatalogRepository {
  final CatalogDataSourcesImp catalogDataSourcesImp;
  CatalogRepositoryImp({required this.catalogDataSourcesImp});
  @override
  Future<List<CatalogEntity>> fetchinterests() async {
    return await catalogDataSourcesImp.getInterests();
  }

  @override
  Future<List<CatalogEntity>> fetchqualities() async {
    return await catalogDataSourcesImp.getQualities();
  }

}