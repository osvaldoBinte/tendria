
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class ProfileModel {
  final String name;
  final String imageUrl;
  final String location;
  final int age;
  final String distance;

  ProfileModel({
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.age,
    required this.distance,
  });
}

class NearbyProfilesController extends GetxController {
  final RxList<ProfileModel> profiles = <ProfileModel>[
    ProfileModel(
      name: 'Elizabeth',
      imageUrl: 'assets/profiles/elizabeth.jpg',
      location: 'Zapopan',
      age: 29,
      distance: '2 km',
    ),
    ProfileModel(
      name: 'Shopia',
      imageUrl: 'assets/profiles/shopia.jpg',
      location: 'Guadalajara',
      age: 25,
      distance: '9 km',
    ),
    ProfileModel(
      name: 'Alejandra',
      imageUrl: 'assets/profiles/alejandra.jpg',
      location: 'Zapopan',
      age: 33,
      distance: '1 km',
    ),
    ProfileModel(
      name: 'Paulina',
      imageUrl: 'assets/profiles/paulina.jpg',
      location: 'Zapopan',
      age: 29,
      distance: '2 km',
    ),
    ProfileModel(
      name: 'Adriana',
      imageUrl: 'assets/profiles/adriana.jpg',
      location: 'Zapopan',
      age: 27,
      distance: '2 km',
    ),
  ].obs;

  final RxInt nearbyCount = 10.obs;

  void onProfileTap(ProfileModel profile) {
    Get.snackbar(
      'Perfil seleccionado',
      'Has seleccionado el perfil de ${profile.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeColor.primaryColor,
      colorText: ThemeColor.textLightColor,
    );
  }
}