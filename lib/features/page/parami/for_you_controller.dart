import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class UserModel {
  final String id;
  final String name;
  final int age;
  final String imageUrl;
  final String bio;
  final String location;
  final double distance;
  final bool isOnline;
  bool isFavorite;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.bio,
    required this.location,
    required this.distance,
    this.isOnline = false,
    this.isFavorite = false,
  });
}

class ForYouController extends GetxController {
  final RxList<UserModel> recommendations = <UserModel>[].obs;
  final RxList<UserModel> activeProfiles = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecommendations();
    loadActiveProfiles();
  }

  void loadRecommendations() {
    recommendations.value = [
      UserModel(
        id: '1',
        name: 'Paola Marcin',
        age: 31,
        imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
        bio: 'Según tu perfil y tus conexiones previas',
        location: 'Guadalajara',
        distance: 2.5,
      ),
      UserModel(
        id: '2',
        name: 'Paola Marcin',
        age: 31,
        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
        bio: 'Según tu perfil y tus conexiones previas',
        location: 'Guadalajara',
        distance: 3.2,
      ),
      UserModel(
        id: '3',
        name: 'Sofia',
        age: 28,
        imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
        bio: 'Según tu perfil y tus conexiones previas',
        location: 'Guadalajara',
        distance: 4.1,
      ),
    ];
  }

  void loadActiveProfiles() {
    activeProfiles.value = [
      UserModel(
        id: '4',
        name: 'Elizabeth',
        age: 29,
        imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
        bio: '',
        location: 'Ubicación: Zapopan',
        distance: 2.8,
        isOnline: true,
      ),
      UserModel(
        id: '5',
        name: 'Shayla',
        age: 27,
        imageUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800',
        bio: '',
        location: 'Ubicación: Guadalajara',
        distance: 3.6,
        isOnline: true,
      ),
    ];
  }

  void toggleFavorite(String userId) {
    final index = recommendations.indexWhere((user) => user.id == userId);
    if (index != -1) {
      recommendations[index].isFavorite = !recommendations[index].isFavorite;
      recommendations.refresh();
      
      Get.snackbar(
        recommendations[index].isFavorite ? 'Agregado' : 'Eliminado',
        recommendations[index].isFavorite
            ? '${recommendations[index].name} fue agregada a favoritos'
            : '${recommendations[index].name} fue eliminada de favoritos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: ThemeColor.primaryColor,
        colorText: ThemeColor.textLightColor,
        duration: const Duration(seconds: 2),
      );
    }
  }
}