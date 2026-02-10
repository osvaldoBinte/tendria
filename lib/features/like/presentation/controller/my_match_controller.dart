import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/features/like/domain/usecase/my_match_usecase.dart';
import 'package:tendria/features/like/domain/entities/matches_entity.dart';

class MyMatchController extends GetxController {
  final MyMatchUsecase myMatchUsecase;
  MyMatchController({required this.myMatchUsecase});

  // Estados reactivos
  final RxList<MatchesEntity> matches = <MatchesEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatches();
  }

  // Cargar matches
  Future<void> loadMatches() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await myMatchUsecase.execute();
      matches.value = result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar matches: $e';
      print('Error loading matches: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refrescar matches
  Future<void> refreshMatches() async {
    await loadMatches();
  }

  // Navegar al chat
  void navigateToChat(int chatId, String name) {
    
    print(  'Navigating to chat with ID: $chatId and name: $name');
    Get.toNamed(RoutesNames.chatPage, arguments: {
      'chatId': chatId,
      'name': name,
    });
  }

  // Navegar al perfil
  void navigateToProfile(int userId) {
    // Implementa tu navegación al perfil
    Get.toNamed('/profile', arguments: {'userId': userId});
  }
}