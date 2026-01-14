
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/features/auth/presentation/page/home/start_page.dart';
import 'package:tendria/features/auth/presentation/page/login/login_page.dart';
import 'package:tendria/features/auth/presentation/page/register/register_page.dart';
import 'package:tendria/features/page/nearbyprofiles/nearby_profiles_page.dart';
import 'package:tendria/features/page/parami/for_you_page.dart';
import 'package:tendria/features/page/profiledetail/profile_detail_page.dart';
class AppPages {
  static final routes = [
   
   
        GetPage(name: RoutesNames.welcomePage, page: () => StartPage()),
        GetPage(name: RoutesNames.foryoupage, page: () => ForYouPage()),
        GetPage(name: RoutesNames.loginPage, page: () => LoginPage()),
        GetPage(name: RoutesNames.registerPage, page: () => RegisterPage()),
        GetPage(name: RoutesNames.homePage, page: () => StartPage()),
        GetPage(name: RoutesNames.nearbyProfilesPage, page: () => NearbyProfilesPage()),
        GetPage(name: RoutesNames.profileDetailPage, page: () => ProfileDetailScreen()),

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