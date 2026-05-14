import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/facebookEvent/domain/usecase/log_view_profile_usecase.dart'; 
import 'package:tendria/features/like/domain/entities/pending_chat_entity.dart';
import 'package:tendria/features/like/presentation/controller/liked_by_users_controller.dart';
import 'package:tendria/features/like/presentation/controller/my_match_controller.dart';
import 'package:tendria/features/stories/presentation/page/story_controller.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart'; 
import 'package:tendria/features/user/domain/usecase/get_user_by_id_usecase.dart';
import 'package:tendria/features/like/domain/usecase/toggle_like_usecase.dart';
import 'package:tendria/features/unlock/domain/usecase/block_user_usecase.dart';
import 'package:tendria/features/user/presentation/controller/nearby_users_controller.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';

class UserProfileController extends GetxController {
  final GetUserByIdUsecase getUserByIdUsecase;
  final ToggleLikeUsecase toggleLikeUsecase;
  final BlockUserUsecase blockUserUsecase;
  final LogViewProfileUsecase logViewProfileUsecase;  

  UserProfileController({
    required this.getUserByIdUsecase,
    required this.toggleLikeUsecase,
    required this.blockUserUsecase,
    required this.logViewProfileUsecase,  
  });

  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxInt currentImageIndex = 0.obs;
  final RxBool isProcessingLike = false.obs;
  final RxBool isProcessingBlock = false.obs;
  final RxBool hasStories = false.obs;

  final Rxn<GetUserEntity> currentUser = Rxn<GetUserEntity>();
  final RxInt userId = 0.obs;
  late PageController pageController;

  String get userName => currentUser.value?.name ?? 'Usuario';
  int get userAge => currentUser.value?.age ?? 0;
  String get userBio => currentUser.value?.bio ?? '';
  List<String> get userInterests =>
      currentUser.value?.interestsIds?.map((i) => i.name).toList() ?? [];
  List<String> get userQualities =>
      currentUser.value?.qualitiesIds?.map((q) => q.name).toList() ?? [];
  List<String> get userGallery => _buildGallery(currentUser.value);
bool get isUserFemale {
  final profileController = Get.find<ProfileController>();
  final g = profileController.gender.toLowerCase().trim();
  return g == 'mujer' || g == 'femenino' || g == 'female' || g == 'Mujer';
}
  final RxInt goPerfilIndex = (-1).obs;
  @override
  void onInit() {
    final args = Get.arguments as Map<String, dynamic>?;
    super.onInit();
    pageController = PageController();
    print('UserProfileController initialized with arguments: ${Get.arguments}');
    if (Get.arguments != null && Get.arguments['userId'] != null) {
      userId.value = Get.arguments['userId'];
      loadUserProfile(userId.value);
    }
    final index = args?['goPerfilIndex'];
 debugPrint('is mujer isUserFemale: $isUserFemale ${ currentUser.value?.gender?.toLowerCase()}');
    if (index is RxInt) {
      goPerfilIndex.value = index.value;
    } else if (index is int) {
      goPerfilIndex.value = index;
    } else {
      goPerfilIndex.value = -1;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> loadUserProfile(int idUser) async {
    try {
      isLoading.value = true;
      final user = await getUserByIdUsecase.execute(idUser);
      print('User profile loaded: ${user.name}, id: ${user.id}');
      currentUser.value = user;
      currentImageIndex.value = 0;
      if (pageController.hasClients) {
        pageController.jumpToPage(0);
      }
      isFavorite.value = false;

      final storyController = Get.find<StoryController>();
      final result = await storyController.fetchStoriesForUser(idUser);
      hasStories.value = result;
 
      await logViewProfileUsecase(targetUserId: idUser.toString());

    } catch (e) {
      print('Error cargando perfil de usuario: $e');
    } finally {
      isLoading.value = false;
    }
  }
  List<String> _buildGallery(GetUserEntity? user) {
    if (user == null) return [''];
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

    if (gallery.isEmpty) gallery.add('');
    return gallery;
  }

  void onPageChanged(int index) {
    currentImageIndex.value = index;
  }

  Future<void> toggleFavorite() async {
    if (currentUser.value == null || isProcessingLike.value) return;

    final previousState = isFavorite.value;
    isFavorite.value = !isFavorite.value;

    try {
      isProcessingLike.value = true;
      await toggleLikeUsecase.execute(
        currentUser.value!.id ?? 0,
        isFavorite.value,
      );
      if (isFavorite.value) {
        showSuccessSnackbar('¡Te gusta $userName!');
      } else {
        showInfoSnackbar('$userName removido de favoritos');
      }
    } catch (e) {
      isFavorite.value = previousState;
      showErrorSnackbar('Error al procesar: ${cleanExceptionMessage(e)}');
    } finally {
      isProcessingLike.value = false;
    }
  }

  Future<void> sendLike() async {
    if (isProcessingLike.value) return;

    try {
      isProcessingLike.value = true;
      await toggleLikeUsecase.execute(userId.value?? 0, true);
      showSuccessSnackbar('¡Le diste like a $userName!');
         final nearbyController = Get.find<NearbyUsersController>();
      nearbyController.noMoreUsers.value = false;
      await nearbyController.loadNearbyUsers();

      Get.offAllNamed(RoutesNames.nearbyProfilesPage);    
    } catch (e) {
      showErrorSnackbar('Error al dar like: ${cleanExceptionMessage(e)}');
    } finally {
      isProcessingLike.value = false;
    }
  }

  Future<void> rejectUser() async {
    if (isProcessingLike.value) return;

    try {
      isProcessingLike.value = true;
      await toggleLikeUsecase.execute(userId.value, false);
      showInfoSnackbar('Usuario rechazado');

      final nearbyController = Get.find<NearbyUsersController>();
      nearbyController.noMoreUsers.value = false;
      await nearbyController.loadNearbyUsers();

      Get.offAllNamed(RoutesNames.nearbyProfilesPage);
    } catch (e) {
      showErrorSnackbar('Error al rechazar: ${cleanExceptionMessage(e)}');
    } finally {
      isProcessingLike.value = false;
    }
  }

  void sendMensaje() {
    final chat = currentUser.value?.chat;

    if (chat != null && chat.pendingAcepted) {
      final likedByController = Get.find<LikedByUsersController>();
      likedByController.unlockChat(
        PendingChatEntity(
          chatId: chat.id,
          userId: userId.value,
          name: userName,
          photoUrl: currentUser.value?.fotoUrl,
          age: currentUser.value?.age,
          hiddenMessage: null,
          createdAt: DateTime.now(),
          unlockCost: 0,
        ),
      );
      return;
    }

    if (chat == null || chat.id == 0) {
      Get.toNamed(
        RoutesNames.chatPage,
        arguments: {'userid': userId.value, 'name': userName, 'goHomeIndex': 2},
      );
      return;
    }

    Get.toNamed(
      RoutesNames.chatPage,
      arguments: {'chatId': chat.id, 'name': userName, 'goHomeIndex': 2},
    );
  }

  void skipUser() => Get.back();

  void blockUser() {
    if (Get.context == null) return;
    showCustomAlert(
      context: Get.context!,
      title: 'Bloquear usuario',
      message: '¿Estás seguro de que quieres bloquear a $userName?',
      confirmText: 'Bloquear',
      cancelText: 'Cancelar',
      type: CustomAlertType.warning,
      onConfirm: _confirmBlock,
    );
  }

  Future<void> _confirmBlock() async {
    if (userId.value == 0 || isProcessingBlock.value) return;

    try {
      isProcessingBlock.value = true;
      final name = userName;
      await blockUserUsecase.execute(userId.value);
      Get.find<MyMatchController>().loadChats();
      Get.back();
      showSuccessSnackbar('$name ha sido bloqueado');
      Get.back();
    } catch (e) {
      showErrorSnackbar('Error al bloquear: ${cleanExceptionMessage(e)}');
      Get.back();
    } finally {
      isProcessingBlock.value = false;
    }
  }

  bool get showRejectButton {
    final chat = currentUser.value?.chat;

    if (chat != null && chat.id != 0) return false;
    return true;
  }

  void reportUser() {
    if (Get.context == null) return;
    showCustomAlert(
      context: Get.context!,
      title: 'Reportar usuario',
      message: '¿Por qué quieres reportar a $userName?',
      confirmText: 'Reportar',
      cancelText: 'Cancelar',
      type: CustomAlertType.warning,
      onConfirm: _confirmReport,
    );
  }

  void _confirmReport() {
    showWarningSnackbar(
      'Gracias por tu reporte. Revisaremos el perfil de $userName',
    );
  }
}
