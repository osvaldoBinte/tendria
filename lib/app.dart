
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/routes/router.dart';
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/auth/presentation/page/Splash/splash_controller.dart';
import 'package:tendria/features/auth/presentation/page/login/login_controller.dart';
import 'package:tendria/features/auth/presentation/page/register/register_controller.dart';
import 'package:tendria/features/chat/presentation/page/chat_controller.dart';
import 'package:tendria/features/like/presentation/controller/liked_by_users_controller.dart';
import 'package:tendria/features/like/presentation/controller/my_match_controller.dart';
import 'package:tendria/features/stories/presentation/page/story_controller.dart';
import 'package:tendria/features/user/presentation/controller/nearby_users_controller.dart';
import 'package:tendria/features/user/presentation/controller/preferences_controller.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';
import 'package:tendria/usecase_config.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
UsecaseConfig usecaseConfig = UsecaseConfig();

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
     locale: const Locale('es', 'ES'),
      supportedLocales: [
        const Locale('es', 'ES'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeColor.themeData, 
      initialBinding: BindingsBuilder(() {
        Get.put(AuthService(), permanent: true);
        Get.put(usecaseConfig.loginUsecase!, permanent: true);
        Get.put(usecaseConfig.createUserUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchInterestsUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchQualitiesUsecase!, permanent: true);
        Get.put(usecaseConfig.postInterestsUsecase!, permanent: true);
        Get.put(usecaseConfig.postQualitiesUsecase!, permanent: true);
        Get.put(usecaseConfig.getUserUsecase!, permanent: true);
        Get.put(usecaseConfig.preferencesUserUsecase!, permanent: true);
        Get.put(usecaseConfig.uploadMediaUsecase!, permanent: true);
        Get.put(usecaseConfig.uploadPicturePerfileUsecase!, permanent:  true);
        Get.put(usecaseConfig.addLikeToStoryUsecase!, permanent: true);
        Get.put(usecaseConfig.createStroryUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchStoriesByIdUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchStoriesUsecase!, permanent: true);
        Get.put(usecaseConfig.removeStoryUsecase!, permanent: true);
        Get.put(usecaseConfig.setStoryAsSeenUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchNearbyUsersUsecase!, permanent: true);
        Get.put(usecaseConfig.getChatMensajeUsecase!,permanent: true);
        Get.put(usecaseConfig.sendMessageUsecase!,permanent: true);
        Get.put(usecaseConfig.getLikeByUsersUsecase!, permanent: true);
        Get.put(usecaseConfig.myMatchUsecase!, permanent: true);
        Get.put(usecaseConfig.toggleLikeUsecase!, permanent: true);

        Get.lazyPut(() => LoginController(loginUsecase: Get.find(), ), fenix: true);
        Get.lazyPut(() => RegisterController(createUserUsecase: Get.find(),fetchQualitiesUsecase: Get.find(), fetchInterestsUsecase: Get.find()), fenix: true);
        Get.lazyPut(()=> SplashController(getUserUsecase: Get.find()), fenix: true);
        Get.lazyPut(() => PreferencesController(preferencesUserUsecase: Get.find(), uploadMediaUsecase: Get.find(), fetchInterestsUsecase: Get.find(), fetchQualitiesUsecase: Get.find(), postInterestsUsecase: Get.find(), postQualitiesUsecase: Get.find()),  fenix: true);
        Get.lazyPut(() => ProfileController(getUserUsecase: Get.find(), uploadMediaUsecase: Get.find(), uploadPicturePerfileUsecase: Get.find()), fenix: true);
        Get.lazyPut(() => StoryController(fetchStoriesUsecase:  Get.find(), addLikeToStoryUsecase:  Get.find(), fetchStoriesByIdUsecase: Get.find(), removeStoryUsecase: Get.find(), createStroryUsecase: Get.find(), setStoryAsSeenUsecase:  Get.find()), fenix:  true);
       //  Get.lazyPut(() => ProfileDetailController( fetchNearbyUsersUsecase: Get.find()), fenix: true);
         Get.lazyPut(()=>NearbyUsersController(fetchNearbyUsersUsecase: Get.find(), toggleLikeUsecase: Get.find()) ,fenix: true);
         Get.lazyPut(() => MyMatchController(myMatchUsecase:  Get.find()), fenix:true);
         Get.lazyPut(() => ChatController( getChatMensajeUsecase: Get.find(), sendMessageUsecase: Get.find()), fenix:true);
         Get.lazyPut(()=> LikedByUsersController( getLikeByUsersUsecase: Get.find(), ), fenix:true);

      }),

      getPages: AppPages.routes, 
      unknownRoute: AppPages.unknownRoute, 
    );
  }
} 