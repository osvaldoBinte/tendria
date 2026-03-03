import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/user/domain/usecase/get_user_usecase.dart';
import 'package:tendria/features/user/presentation/controller/update_profile_controller.dart';

class SplashController extends GetxController {
  final RxBool isLoading = true.obs;

  final GetUserUsecase getUserUsecase;

  SplashController({required this.getUserUsecase});

  @override
  void onInit() async {
    super.onInit();
    await checkUserSession();
    await requestLocationPermission();
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

  /// Obtiene la ciudad actual del GPS y la actualiza en el perfil
  Future<void> _updateUserCity() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // low es suficiente para ciudad
        timeLimit: const Duration(seconds: 10),
      );

      // Convertir coordenadas → nombre de ciudad
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Preferir locality (ciudad), fallback a subAdminArea (municipio)
        final city = place.locality?.isNotEmpty == true
            ? place.locality!
            : place.subAdministrativeArea ?? '';

        if (city.isNotEmpty) {
          // Solo actualizar si el controller ya está registrado (usuario con sesión)
          print('city : $city');
          final updater =
              Get.isRegistered<UpdateProfileController>()
                  ? Get.find<UpdateProfileController>()
                  : null;

          await updater?.updateCity(city);
        }
      }
    } catch (_) {
      // Silencioso — no bloquear el splash por un error de ubicación
    }
  }

  Future<void> checkUserSession() async {
    try {
      await getUserUsecase.execute();
      Get.offAllNamed(RoutesNames.preferencesPage);
    } catch (e) {
      print('Error checking user session: $e');
      Get.offAllNamed(RoutesNames.loginPage);
    } finally {
      isLoading.value = false;
    }
  }
}