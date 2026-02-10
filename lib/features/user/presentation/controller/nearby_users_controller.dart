import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/usecase/fetch_nearby_users_usecase.dart';
import 'package:tendria/features/like/domain/usecase/toggle_like_usecase.dart';

class ProfileDetailModel {
  final String name;
  final int age;
  final String distance;
  final String bio;
  final List<String> interests;
  final List<String> qualities;
  final List<String> gallery;

  ProfileDetailModel({
    required this.name,
    required this.age,
    required this.distance,
    required this.bio,
    this.interests = const [],
    this.qualities = const [],
    this.gallery = const [],
  });
}

class NearbyUsersController extends GetxController {
  final FetchNearbyUsersUsecase fetchNearbyUsersUsecase;
  final ToggleLikeUsecase toggleLikeUsecase;

  NearbyUsersController({
    required this.fetchNearbyUsersUsecase,
    required this.toggleLikeUsecase,
  });

  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxInt currentImageIndex = 0.obs;
  final RxBool isProcessingLike = false.obs;
  
  final RxList<GetUserEntity> nearbyUsers = <GetUserEntity>[].obs;
  final RxList<GetUserEntity> currentRadarUsers = <GetUserEntity>[].obs;
  final RxInt currentUserIndex = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 3.obs;
  
  late Rx<ProfileDetailModel> profile;
  late PageController pageController;

  GetUserEntity? get currentUser {
    if (nearbyUsers.isEmpty || currentUserIndex.value >= nearbyUsers.length) {
      return null;
    }
    return nearbyUsers[currentUserIndex.value];
  }

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    
    profile = ProfileDetailModel(
      name: 'Cargando...',
      age: 0,
      distance: '0 km',
      bio: '',
      interests: [],
      qualities: [],
      gallery: [],
    ).obs;
    
    loadNearbyUsers();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> loadNearbyUsers() async {
    try {
      isLoading.value = true;
      final users = await fetchNearbyUsersUsecase.execute(
        currentPage.value,
        pageSize.value,
      );
      
      if (users.isEmpty) {
        showInfoSnackbar('No hay más usuarios cercanos');
        return;
      }
      
      users.sort((a, b) {
        final distanceA = double.tryParse(a.bio ?? '0') ?? 0.0;
        final distanceB = double.tryParse(b.bio ?? '0') ?? 0.0;
        return distanceA.compareTo(distanceB);
      });
      
      nearbyUsers.value = users;
      currentRadarUsers.value = users;
      currentUserIndex.value = 0;
      updateCurrentProfile();
    } catch (e) {
      print('Error cargando usuarios: $e');
      showErrorSnackbar('No se pudieron cargar los usuarios: ${cleanExceptionMessage(e)}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNextBatch() async {
    currentPage.value++;
    await loadNearbyUsers();
  }

  void updateCurrentProfile() { 
    if (nearbyUsers.isEmpty || currentUserIndex.value >= nearbyUsers.length) {
      return;
    }

    final user = nearbyUsers[currentUserIndex.value];
    
    profile.value = ProfileDetailModel(
      name: user.name ?? 'Usuario',
      age: user.age ?? 0,
      distance: _calculateDistance(user),
      bio: user.bio ?? 'Apasionado por la vida y nuevas experiencias',
      interests: user.interestsIds?.map((i) => i.name).toList() ?? [],
      qualities: user.qualitiesIds?.map((q) => q.name).toList() ?? [],
      gallery: _buildGallery(user),
    );

    currentImageIndex.value = 0;
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }

    isFavorite.value = false;
  }

  String _calculateDistance(GetUserEntity user) {
    if (user.bio != null && user.bio!.isNotEmpty) {
      final distance = double.tryParse(user.bio!) ?? 0.0;
      return '${distance.toStringAsFixed(2)} km cerca';
    }
    return '${(2 + (currentUserIndex.value % 10))} km cerca';
  }

  List<String> _buildGallery(GetUserEntity user) {
    final gallery = <String>[];
    
    if (user.fotoUrl != null && user.fotoUrl!.isNotEmpty) {
      gallery.add(user.fotoUrl!);
    }
   
    if (user.assets != null && user.assets!.isNotEmpty) {
      final sortedAssets = user.assets!.toList()
        ..sort((a, b) => a.orden.compareTo(b.orden));
      
      for (var asset in sortedAssets) {
        if (!gallery.contains(asset.url)) {
          gallery.add(asset.url);
        }
      }
    }
    
    if (gallery.isEmpty) {
      gallery.add('');
    }
    
    return gallery;
  }

  void nextUser() {
    if (currentUserIndex.value < nearbyUsers.length - 1) {
      currentUserIndex.value++;
      updateCurrentProfile();
    } else {
      showInfoSnackbar('No hay más personas disponibles');
  
      loadNextBatch();
    }
  }

  void onPageChanged(int index) {
    currentImageIndex.value = index;
  }

  Future<void> toggleFavorite() async {
    if (currentUser == null || isProcessingLike.value) return;

    final previousState = isFavorite.value;
    isFavorite.value = !isFavorite.value;

    try {
      isProcessingLike.value = true;

      await toggleLikeUsecase.execute(
        currentUser!.id ?? 0,
        isFavorite.value, 
      );

      if (isFavorite.value) {
        showSuccessSnackbar('¡Te gusta ${profile.value.name}!');
      } else {
        showInfoSnackbar('${profile.value.name} removido de favoritos');
      }

      if (isFavorite.value) {
        Future.delayed(Duration(milliseconds: 1000), () {
          nextUser();
        });
      }
    } catch (e) {
      isFavorite.value = previousState;
      showErrorSnackbar('Error al procesar: ${cleanExceptionMessage(e)}');
      print('Error toggling like: $e');
    } finally {
      isProcessingLike.value = false;
    }
  }

  Future<void> sendLike() async {
    if (currentUser == null || isProcessingLike.value) return;

    try {
      isProcessingLike.value = true;

      await toggleLikeUsecase.execute(currentUser!.id ?? 0, true);

      showSuccessSnackbar('¡Le diste like a ${profile.value.name}!');

      Future.delayed(Duration(milliseconds: 1000), () {
        nextUser();
      });
    } catch (e) {
      showErrorSnackbar('Error al dar like: ${cleanExceptionMessage(e)}');
      print('Error sending like: $e');
    } finally {
      isProcessingLike.value = false;
    }
  }

  Future<void> rejectUser() async {
    if (currentUser == null || isProcessingLike.value) return;

    try {
      isProcessingLike.value = true;

      await toggleLikeUsecase.execute(currentUser!.id ?? 0, false);

      showInfoSnackbar('Pasando al siguiente perfil');

      nextUser();
    } catch (e) {
      showErrorSnackbar('Error al rechazar: ${cleanExceptionMessage(e)}');
      print('Error rejecting user: $e');
    } finally {
      isProcessingLike.value = false;
    }
  }

  void sendMessage() {
    sendLike();
  }

  void sendSuperLike() {
    showInfoSnackbar('Le has enviado un Super Like a ${profile.value.name}');

    Future.delayed(Duration(milliseconds: 1000), () {
      nextUser();
    });
  }

  void skipUser() {
    rejectUser();
  }

  void blockUser() {
    if (Get.context == null) return;
    
    showCustomAlert(
      context: Get.context!,
      title: 'Bloquear usuario',
      message: '¿Estás seguro de que quieres bloquear a ${profile.value.name}?',
      confirmText: 'Bloquear',
      cancelText: 'Cancelar',
      type: CustomAlertType.warning,
      onConfirm: _confirmBlock,
    );
  }

  void _confirmBlock() {
    final userName = profile.value.name;
    
    nearbyUsers.removeAt(currentUserIndex.value);
    currentRadarUsers.removeAt(currentUserIndex.value);
    
    if (currentUserIndex.value >= nearbyUsers.length) {
      currentUserIndex.value = nearbyUsers.length - 1;
    }
    
    showErrorSnackbar('$userName ha sido bloqueado');

    if (nearbyUsers.isEmpty) {
      showWarningSnackbar('Has visto todos los perfiles disponibles');
      Future.delayed(Duration(milliseconds: 1500), () => Get.back());
    } else {
      updateCurrentProfile();
    }
  }

  void reportUser() {
    if (Get.context == null) return;
    
    showCustomAlert(
      context: Get.context!,
      title: 'Reportar usuario',
      message: '¿Por qué quieres reportar a ${profile.value.name}?',
      confirmText: 'Reportar',
      cancelText: 'Cancelar',
      type: CustomAlertType.warning,
      onConfirm: _confirmReport,
    );
  }

  void _confirmReport() {
    showWarningSnackbar('Gracias por tu reporte. Revisaremos el perfil de ${profile.value.name}');
  }
}