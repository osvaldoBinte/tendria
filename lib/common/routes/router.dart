
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart'; 
import 'package:tendria/features/auth/presentation/page/Splash/splash_page.dart';
import 'package:tendria/features/auth/presentation/page/home/start_page.dart';
import 'package:tendria/features/auth/presentation/page/login/login_page.dart';
import 'package:tendria/features/auth/presentation/page/register/register_page.dart';
import 'package:tendria/features/chat/presentation/page/chat_page.dart'; 
import 'package:tendria/features/notification/presentation/page/notificasiones/notification_page.dart'; 
import 'package:tendria/features/page/parami/for_you_page.dart';
import 'package:tendria/features/page/valueOfContent/value_of_content.dart';
import 'package:tendria/features/purchase/presentation/page/purchase_page.dart';
import 'package:tendria/features/unlock/presentation/page/blocked_users_page.dart';
import 'package:tendria/features/user/presentation/page/profile/update_profile_page.dart';
import 'package:tendria/features/user/presentation/page/radarscanner/radar_scanner_page.dart';
import 'package:tendria/features/user/presentation/profiledetail/nearby_users_page.dart';
import 'package:tendria/features/user/presentation/page/preferences/preferences_page.dart';
import 'package:tendria/features/user/presentation/profiledetail/user_profile_detail_page.dart';
import 'package:tendria/features/verifications/presentation/page/verification_page.dart';
class AppPages {
  static final routes = [
   
   
        GetPage(name: RoutesNames.welcomePage, page: () => valueOfContent()),
        GetPage(name: RoutesNames.chatPage, page: () => ChatPage()),
        GetPage(name: RoutesNames.radarScannerPage, page: () => RadarScannerScreen()),
        GetPage(name: RoutesNames.preferencesPage, page: () => PreferencesPage()),
        GetPage(name: RoutesNames.foryoupage, page: () => ForYouPage()),
        GetPage(name: RoutesNames.loginPage, page: () => LoginPage()),
        GetPage(name: RoutesNames.registerPage, page: () => RegisterPage()),
        GetPage(name: RoutesNames.homePage, page: () => StartPage()),
        GetPage(name: RoutesNames.nearbyProfilesPage, page: () => NearbyUsersPage()),
        GetPage(name: RoutesNames.profileDetailPage, page: () => NearbyUsersPage()),
        GetPage(name: RoutesNames.userProfileDetailPage, page: () => UserProfileDetailPage()),
        GetPage(name: RoutesNames.blockedUsersPage, page: () => BlockedUsersPage()),
        GetPage(name: RoutesNames.updateProfilePage, page: () => UpdateProfilePage()), 
        GetPage (name: RoutesNames.notificationPage, page: () => NotificationPage()),
        GetPage(name: RoutesNames.purchasePage, page: () =>PurchasePage()),
        GetPage(name: RoutesNames.verificationPage, page: () => VerificationPage()),

        GetPage(name: RoutesNames.valueOfContentPage, page: () => valueOfContent()),
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