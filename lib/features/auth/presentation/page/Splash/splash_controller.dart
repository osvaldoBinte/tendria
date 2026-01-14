
import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
class SplashController extends GetxController {
  final RxBool isLoading = true.obs;
  
 // final GetUserDetailsUsecase getUserDetailsUsecase;
  
 // SplashController({required this.getUserDetailsUsecase});
  
  @override
  void onInit()  async{
    super.onInit();
   await checkUserSession();

  }
  
  Future<void> checkUserSession() async {
    try {
     
    //  await getUserDetailsUsecase.execute();
   Get.offAllNamed(RoutesNames.homePage, arguments: 0);


    } catch (e) {
      print('Error checking user session: $e');
      Get.offAllNamed(RoutesNames.loginPage);
    } finally {
      isLoading.value = false;
    }
  }
 

}