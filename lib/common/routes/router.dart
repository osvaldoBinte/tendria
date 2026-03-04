
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/widgets/tutorial_page.dart';
import 'package:tendria/features/auth/presentation/page/Splash/splash_page.dart';
import 'package:tendria/features/auth/presentation/page/home/start_page.dart';
import 'package:tendria/features/auth/presentation/page/login/login_page.dart';
import 'package:tendria/features/auth/presentation/page/register/register_page.dart';
import 'package:tendria/features/chat/presentation/page/chat_page.dart';
import 'package:tendria/features/like/presentation/page/start_conversations_page.dart';
import 'package:tendria/features/page/nearbyprofiles/nearby_profiles_page.dart';
import 'package:tendria/features/page/parami/for_you_page.dart';
import 'package:tendria/features/unlock/presentation/page/blocked_users_page.dart';
import 'package:tendria/features/user/presentation/page/profile/update_profile_page.dart';
import 'package:tendria/features/user/presentation/page/radarscanner/radar_scanner_page.dart';
import 'package:tendria/features/user/presentation/profiledetail/profile_detail_page.dart';
import 'package:tendria/features/user/presentation/page/preferences/preferences_page.dart';
import 'package:tendria/features/user/presentation/profiledetail/user_profile_detail_page.dart';
class AppPages {
  static final routes = [
   
   
        GetPage(name: RoutesNames.welcomePage, page: () => SplashPage()),
        GetPage(name: RoutesNames.chatPage, page: () => ChatPage()),
        GetPage(name: RoutesNames.radarScannerPage, page: () => RadarScannerScreen()),
        GetPage(name: RoutesNames.preferencesPage, page: () => PreferencesPage()),
        GetPage(name: RoutesNames.foryoupage, page: () => ForYouPage()),
        GetPage(name: RoutesNames.loginPage, page: () => LoginPage()),
        GetPage(name: RoutesNames.registerPage, page: () => RegisterPage()),
        GetPage(name: RoutesNames.homePage, page: () => StartPage()),
        GetPage(name: RoutesNames.nearbyProfilesPage, page: () => NearbyProfilesPage()),
        GetPage(name: RoutesNames.profileDetailPage, page: () => ProfileDetailScreen()),
        GetPage(name: RoutesNames.userProfileDetailPage, page: () => UserProfileDetailPage()),
        GetPage(name: RoutesNames.blockedUsersPage, page: () => BlockedUsersPage()),
        GetPage(name: RoutesNames.updateProfilePage, page: () => UpdateProfilePage()),
        GetPage(name: RoutesNames.tutorialPage, page: () => TutorialPage()),
  ];

  static final unknownRoute = GetPage(
    name: '/not-found',
    page: () => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada'),
      ),
    ),
  );
}