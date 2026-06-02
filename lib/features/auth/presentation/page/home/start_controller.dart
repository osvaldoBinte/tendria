import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tendria/common/tutorial/tutorialPerfil/profile_tutorial_controller.dart';
import 'package:tendria/common/tutorial/tutorial_controller.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/features/like/presentation/page/liked_by_users_page.dart';
import 'package:tendria/features/like/presentation/page/my_match_page.dart';
import 'package:tendria/features/user/domain/entities/update_location_entity.dart';
import 'package:tendria/features/user/domain/usecase/update_location_usecase.dart';
import 'package:tendria/features/user/presentation/controller/nearby_users_controller.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';
import 'package:tendria/features/user/presentation/page/profile/profile_page.dart';
import 'package:tendria/features/user/presentation/page/radarscanner/radar_scanner_page.dart';
import 'package:tendria/features/user/presentation/profiledetail/nearby_users_page.dart';

class StartController extends GetxController with WidgetsBindingObserver { 
  final UpdateLocationUsecase updateLocationUsecase;

  StartController({required this.updateLocationUsecase});
 
  final List<Widget> pages = [
    ProfilePage(),
    RadarScannerScreen(),
    LikedByUsersView(),
    MyMatchView(),
  ];

  final List<String> labels = ['Perfil', 'Radar', 'Match', 'Chat'];

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
 
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _checkProfileCompletion();
    _handleInitialTab(); 
    _updateUserCity();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
 
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) { 
      _updateUserCity();
    }
  }
 
 Future<void> _updateUserCity() async {
  try {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 10),
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      final city = _resolveCity(place);

      if (city.isNotEmpty) {
        final country = place.country?.trim() ?? '';
        print('city: $city | country: $country');
        
        await updateLocationUsecase.execute(
          UpdateLocationEntity(
            latitude: position.latitude,
            longitude: position.longitude,
            city: city,
            country: country,
          ),
        );
 
        try {
          final nearbyCtrl = Get.find<NearbyUsersController>();
          nearbyCtrl.loadNearbyUsers();
        } catch (_) { 
        }
      }
    }
  } catch (e) {
    print('Error obteniendo ubicación: $e');
  }
}

  String _resolveCity(Placemark place) {
    return place.locality?.trim().isNotEmpty == true
        ? place.locality!.trim()
        : place.subAdministrativeArea?.trim().isNotEmpty == true
        ? place.subAdministrativeArea!.trim()
        : place.administrativeArea?.trim() ?? '';
  }
 
  void changePage(int index) {
    if (selectedIndex.value == 0) {
      try {
        final profileTutorial = Get.find<ProfileTutorialController>();
        if (profileTutorial.isVisible.value) return;
      } catch (_) {}
    }
    if (selectedIndex.value == 1) {
      try {
        final radarTutorial = Get.find<TutorialController>();
        if (radarTutorial.isVisible.value) return;
      } catch (_) {}
    }
    selectedIndex.value = index;
  }

  Widget get currentPage => pages[selectedIndex.value];

  String getIconPath(int index) {
    return selectedIndex.value == index
        ? selectedIconPaths[index]
        : iconPaths[index];
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
      await Future.delayed(const Duration(milliseconds: 500));

      ProfileController? profileController;
      try {
        profileController = Get.find<ProfileController>();
      } catch (e) {
        print('ProfileController no encontrado');
      }

      if (profileController == null) return;

      if (profileController.isLoading.value) {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      final user = profileController.userEntity.value;
      if (user == null) return;

      final hasPreferences = user.preferences != null &&
          user.preferences!.searchgender != null;
      final hasPhotos = user.assets != null &&
          user.assets!.isNotEmpty &&
          user.assets!.length >= 2;
      final hasInterests =
          user.interestsIds != null && user.interestsIds!.isNotEmpty;
      final hasQualities =
          user.qualitiesIds != null && user.qualitiesIds!.isNotEmpty;

      if (!hasPreferences || !hasPhotos || !hasInterests || !hasQualities) {
        print('Perfil incompleto, redirigiendo a preferencias...');
        _navigateToPreferences();
      } else {
        print('Perfil completo, mostrando StartPage');
        isCheckingProfile.value = false;
      }
    } catch (e) {
      print('Error verificando perfil: $e');
    } finally {
      isCheckingProfile.value = false;
    }
  }

  void _navigateToPreferences() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.offAllNamed(RoutesNames.preferencesPage);
    });
  }
}