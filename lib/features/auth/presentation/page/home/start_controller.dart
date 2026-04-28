

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/features/like/presentation/page/liked_by_users_page.dart';
import 'package:tendria/features/like/presentation/page/my_match_page.dart';
import 'package:tendria/features/page/parami/for_you_page.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';
import 'package:tendria/features/user/presentation/page/profile/profile_page.dart';
import 'package:tendria/features/user/presentation/page/radarscanner/radar_scanner_page.dart';
import 'package:tendria/features/user/presentation/profiledetail/nearby_users_page.dart';

class StartController extends GetxController {
  final List<Widget> pages = [
    ProfilePage(),
    RadarScannerScreen(),
    LikedByUsersView(),
    MyMatchView(),
  ];
final List<String> labels = [
  'Perfil',
  'Radar',
  'Match',
  'Chat',
];
  final List<String> iconPaths = [
    'assets/icons/home/perfil.png',
    'assets/icons/home/parati.png', 
    
    'assets/icons/home/heart.png',
    'assets/icons/home/mensaje.png',
  ];

  final List<String> selectedIconPaths = [
    'assets/icons/home/perfil.png',
    'assets/icons/home/parati.png', 
    
    'assets/icons/home/heart.png',
    'assets/icons/home/mensaje.png',
  ];

  final RxInt selectedIndex = 0.obs; 
  

  final RxBool isCheckingProfile = true.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }

  Widget get currentPage => pages[selectedIndex.value];

  String getIconPath(int index) {
    return selectedIndex.value == index 
        ? selectedIconPaths[index] 
        : iconPaths[index];
  }
@override
void onInit() {
  super.onInit();
  _checkProfileCompletion();
  _handleInitialTab(); 
  
}

void _handleInitialTab() {
  final args = Get.arguments as Map<String, dynamic>?;
  final tab = args?['tab'] as int?;
  
  
  if (tab != null && tab >= 0 && tab < pages.length) {
    selectedIndex.value = tab;
  }
}


  Future<void> _checkProfileCompletion() async {
    try {
      isCheckingProfile.value = true;
      
      
      await Future.delayed(Duration(milliseconds: 500));
      
      
      ProfileController? profileController;
      try {
        profileController = Get.find<ProfileController>();
      } catch (e) {
        print('ProfileController no encontrado');
      }


      if (profileController == null) {
     //   _navigateToPreferences();
        return;
      }


      if (profileController.isLoading.value) {
        await Future.delayed(Duration(milliseconds: 1000));
      }


      final user = profileController.userEntity.value;
      
      if (user == null) {
      //  _navigateToPreferences();
        return;
      }


final hasPreferences = user.preferences != null &&
                      user.preferences!.searchgender != null;
      
      final hasPhotos = user.assets != null && 
                       user.assets!.isNotEmpty && 
                       user.assets!.length >= 2;
      
      final hasInterests = user.interestsIds != null && 
                          user.interestsIds!.isNotEmpty;
      
      final hasQualities = user.qualitiesIds != null && 
                          user.qualitiesIds!.isNotEmpty;


      if (!hasPreferences || !hasPhotos || !hasInterests || !hasQualities) {
        print('Perfil incompleto, redirigiendo a preferencias...');
        _navigateToPreferences();
      } else {
        print('Perfil completo, mostrando StartPage');
        isCheckingProfile.value = false;
      }
    } catch (e) {
      print('Error verificando perfil: $e');
  //    _navigateToPreferences();
    } finally {
      isCheckingProfile.value = false;
    }
  }

  void _navigateToPreferences() {
    
    Future.delayed(Duration(milliseconds: 100), () {
      Get.offAllNamed(RoutesNames.preferencesPage);
    });
  }

  @override
  void onClose() {
    super.onClose();
  }
}