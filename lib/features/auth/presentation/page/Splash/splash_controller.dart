
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/user/domain/usecase/get_user_usecase.dart';
class SplashController extends GetxController {
  final RxBool isLoading = true.obs;
  
  final GetUserUsecase getUserUsecase;
  
  SplashController({required this.getUserUsecase});
  
  @override
  void onInit()  async{
    super.onInit();
   await checkUserSession();
   await requestLocationPermission();

  }

  Future<void> requestLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
   
        showErrorSnackbar('Por favor activa los servicios de ubicación para usar la aplicaciór');

    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      showErrorSnackbar('Se requieren permisos de ubicación para usar la aplicación');

      return;
    }
  }

  return;
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