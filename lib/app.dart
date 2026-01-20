
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:tendria/common/routes/router.dart';
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/auth/presentation/page/Splash/splash_controller.dart';
import 'package:tendria/features/auth/presentation/page/login/login_controller.dart';
import 'package:tendria/features/auth/presentation/page/register/register_controller.dart';
import 'package:tendria/usecase_config.dart';

UsecaseConfig usecaseConfig = UsecaseConfig();

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
    
      debugShowCheckedModeBanner: false,
      theme: ThemeColor.themeData, 
      initialBinding: BindingsBuilder(() {
        Get.put(AuthService(), permanent: true);
        Get.put(usecaseConfig.loginUsecase!, permanent: true);
        Get.put(usecaseConfig.createUserUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchInterestsUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchQualitiesUsecase!, permanent: true);
        Get.put(usecaseConfig.getUserUsecase!, permanent: true);

        Get.lazyPut(() => LoginController(loginUsecase: Get.find(), ), fenix: true);
        Get.lazyPut(() => RegisterController(createUserUsecase: Get.find(),fetchQualitiesUsecase: Get.find(), fetchInterestsUsecase: Get.find()), fenix: true);
        Get.lazyPut(()=> SplashController(getUserUsecase: Get.find()), fenix: true);

      }),

      getPages: AppPages.routes, 
      unknownRoute: AppPages.unknownRoute, 
    );
  }
} 