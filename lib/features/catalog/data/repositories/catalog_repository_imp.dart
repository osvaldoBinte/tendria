import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/features/catalog/data/datasources/catalog_data_sources_imp.dart';
import 'package:tendria/features/catalog/domain/entities/catalog_entity.dart';
import 'package:tendria/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImp extends CatalogRepository {
  final CatalogDataSourcesImp catalogDataSourcesImp;
  AuthService authService = AuthService();
  CatalogRepositoryImp({required this.catalogDataSourcesImp});
  @override
  Future<List<CatalogEntity>> fetchinterests() async {
    return await catalogDataSourcesImp.getInterests();
  }

  @override
  Future<List<CatalogEntity>> fetchqualities() async {
    return await catalogDataSourcesImp.getQualities();
  }
  
  @override
  Future<void> postInterests(List<int> interestsIds) async {
     final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await catalogDataSourcesImp.postInterests(interestsIds,token);
  }
  
  @override
  Future<void> postQualities(List<int> qualitiesIds) async {
     final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await catalogDataSourcesImp.postQualities(qualitiesIds,token);
  }
  
  @override
  Future<void> deleteinterests(List<int> interestsIds) async {
     final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await catalogDataSourcesImp.deleteInterests(interestsIds,token);
   
  }
  
  @override
  Future<void> deletequalities(List<int> qualitiesIds) async {
     final token = await authService.getToken()?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await catalogDataSourcesImp.deleteQualities(qualitiesIds,token);

  }

}