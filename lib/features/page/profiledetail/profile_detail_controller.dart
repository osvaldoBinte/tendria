import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class ProfileDetailModel {
  final String name;
  final int age;
  final String distance;
  final String bio;
  final List<String> interests;
  final List<String> gallery;

  ProfileDetailModel({
    required this.name,
    required this.age,
    required this.distance,
    required this.bio,
    this.interests = const [],
    this.gallery = const [],
  });
}

class ProfileDetailController extends GetxController {
  final RxBool isFavorite = false.obs;
  final RxInt currentImageIndex = 0.obs;
  
  late Rx<ProfileDetailModel> profile;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    
    profile = ProfileDetailModel(
      name: 'Alexia',
      age: 28,
      distance: '2 km cerca',
      bio: 'Trabajadora, divertida, honesta y con mil sueños por cumplir...',
      interests: ['Música', 'Viajes', 'Fotografía', 'Café', 'Arte'],
      gallery: [
        'https://i.blogs.es/ed843e/superpc-ap/1366_2000.jpeg',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
      ],
    ).obs;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentImageIndex.value = index;
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    Get.snackbar(
      isFavorite.value ? 'Agregado a favoritos' : 'Eliminado de favoritos',
      isFavorite.value 
          ? '${profile.value.name} fue agregada a tus favoritos'
          : '${profile.value.name} fue eliminada de tus favoritos',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeColor.primaryColor,
      colorText: ThemeColor.textLightColor,
      duration: const Duration(seconds: 2),
    );
  }

  void sendMessage() {
    Get.snackbar(
      'Mensaje',
      'Abriendo chat con ${profile.value.name}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeColor.accentColor,
      colorText: ThemeColor.textLightColor,
    );
  }

  void sendSuperLike() {
    Get.snackbar(
      'Super Like',
      'Le has enviado un Super Like a ${profile.value.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeColor.secondaryColor,
      colorText: ThemeColor.textLightColor,
    );
  }
}