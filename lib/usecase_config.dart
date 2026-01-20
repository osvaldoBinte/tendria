import 'package:tendria/features/auth/data/datasource/auth_data_source_imp.dart';
import 'package:tendria/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:tendria/features/auth/domain/usecase/create_user_usecase.dart';
import 'package:tendria/features/auth/domain/usecase/login_usecase.dart';
import 'package:tendria/features/catalog/data/datasources/catalog_data_sources_imp.dart';
import 'package:tendria/features/catalog/data/repositories/catalog_repository_imp.dart';
import 'package:tendria/features/catalog/domain/usecase/fetch_interests_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/fetch_qualities_usecase.dart';
import 'package:tendria/features/user/data/datasources/user_data_sources_imp.dart';
import 'package:tendria/features/user/data/repositories/user_repository_imp.dart';
import 'package:tendria/features/user/domain/usecase/get_user_usecase.dart';

class UsecaseConfig {
  AuthDataSourceImp? authDataSourceImp;
  CatalogDataSourcesImp? catalogDataSourcesImp;
  UserDataSourcesImp? userDataSourcesImp;

  AuthRepositoryImp? authRepositoryImp;
  CatalogRepositoryImp? catalogRepositoryImp;
  UserRepositoryImp? userRepositoryImp;

  LoginUsecase? loginUsecase;
  CreateUserUsecase? createUserUsecase;

  FetchInterestsUsecase? fetchInterestsUsecase;
  FetchQualitiesUsecase? fetchQualitiesUsecase;
  
  GetUserUsecase? getUserUsecase;

  
  UsecaseConfig(){
    authDataSourceImp = AuthDataSourceImp();
    userDataSourcesImp = UserDataSourcesImp();
    catalogDataSourcesImp = CatalogDataSourcesImp();
    authRepositoryImp = AuthRepositoryImp(authDataSourceImp: authDataSourceImp!);
    catalogRepositoryImp = CatalogRepositoryImp(catalogDataSourcesImp: catalogDataSourcesImp!);
    userRepositoryImp = UserRepositoryImp(userDataSourcesImp: userDataSourcesImp!);

    loginUsecase = LoginUsecase(authRepository: authRepositoryImp!);
    createUserUsecase = CreateUserUsecase(authRepository: authRepositoryImp!);
    fetchInterestsUsecase = FetchInterestsUsecase(catalogRepository: catalogRepositoryImp!);
    fetchQualitiesUsecase = FetchQualitiesUsecase(catalogRepository: catalogRepositoryImp!);
    getUserUsecase = GetUserUsecase(userRepository: userRepositoryImp!);
  }
}