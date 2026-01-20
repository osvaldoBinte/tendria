
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
  Future<bool> requestLocationPermission() async {
  final status = await Permission.locationWhenInUse.request();

  if (status.isGranted) {
    return true;
  }

  if (status.isDenied) {
    showErrorSnackbar('Debes permitir la ubicación para continuar');
  
    return false;
  }
if (status.isPermanentlyDenied) {
  showCustomAlert(
    context: Get.context!, // GetX nos da el context
    title: 'Permiso de ubicación',
    message: 'Debes habilitar la ubicación desde ajustes para continuar',
    confirmText: 'Abrir ajustes',
    cancelText: 'Cancelar',
    type: CustomAlertType.warning,
    onConfirm: () async {
      Get.back();
      await openAppSettings();
    },
    onCancel: () {
      Get.back();
    },
  );

  return false;
}


  return false;
}

  Future<void> checkUserSession() async {
    try {
     
      await getUserUsecase.call();
   Get.offAllNamed(RoutesNames.homePage);


    } catch (e) {
      print('Error checking user session: $e');
      Get.offAllNamed(RoutesNames.loginPage);
    } finally {
      isLoading.value = false;
    }
  }
 

}