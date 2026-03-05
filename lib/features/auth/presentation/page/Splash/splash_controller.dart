import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/user/domain/entities/update_location_entity.dart';
import 'package:tendria/features/user/domain/usecase/get_user_usecase.dart';
import 'package:tendria/features/user/domain/usecase/update_location_usecase.dart';
import 'package:tendria/features/user/presentation/controller/update_profile_controller.dart';

class SplashController extends GetxController {
  final UpdateLocationUsecase updateLocationUsecase;
  final RxBool isLoading = true.obs;

  final GetUserUsecase getUserUsecase;

  SplashController({required this.getUserUsecase, required this.updateLocationUsecase});

  @override
  void onInit() async {
    super.onInit();
    await checkUserSession();
    await requestLocationPermission();
          await _requestNotificationPermission();

  }

  Future<void> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showErrorSnackbar(
          'Por favor activa los servicios de ubicación para usar la aplicación');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showErrorSnackbar(
            'Se requieren permisos de ubicación para usar la aplicación');
        return;
      }
    }

    // Si tenemos permiso, obtener y actualizar la ciudad
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await _updateUserCity();
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
      final city = place.locality?.isNotEmpty == true
          ? place.locality!
          : place.subAdministrativeArea ?? '';

      if (city.isNotEmpty) {
        print('city : $city');

        await updateLocationUsecase.execute(
          UpdateLocationEntity(
            latitude: position.latitude,
            longitude: position.longitude,
            city: city,
          ),
        );
      }
    }
  } catch (e) {
    print('Error obteniendo ubicación: $e');
  }
}
Future<void> checkUserSession() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    const String tutorialKey = AppConstants.tutorialKey;
    
    final hasSeenTutorial = prefs.getBool(tutorialKey) ?? false;
    
    print('hasSeenTutorial: $hasSeenTutorial');

    if (!hasSeenTutorial) {
      Get.offAllNamed(RoutesNames.tutorialPage);
      return;
    }

    await getUserUsecase.execute();
    Get.offAllNamed(RoutesNames.preferencesPage);
  } catch (e) {
    Get.offAllNamed(RoutesNames.loginPage);
  } finally {
    isLoading.value = false;
  }
}
Future<void> _requestNotificationPermission() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Estado de permisos: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisos de notificaciones concedidos');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('Permisos provisionales concedidos');
    } else {
      print('Permisos de notificaciones denegados');
    }
  }
}