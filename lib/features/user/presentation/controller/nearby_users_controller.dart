import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/stories/presentation/page/story_controller.dart';
import 'package:tendria/features/stories/presentation/page/story_modal_widget.dart';
import 'package:tendria/features/stories/presentation/page/target_user_story_modal.dart';
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
  final RxInt pageSize = 6.obs;

  // ── Stories indicator per user ──
  final RxMap<int, bool> userHasStories = <int, bool>{}.obs;

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

      // Pre-cargar indicador de historias para cada usuario en segundo plano
      _preloadStoryIndicators(users);
    } catch (e) {
      showErrorSnackbar(
        'No se pudieron cargar los usuarios: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Consulta en segundo plano si cada usuario tiene historias activas.
  void _preloadStoryIndicators(List<GetUserEntity> users) {
    final storyController = Get.find<StoryController>();
    for (final user in users) {
      if (user.id == null) continue;
      storyController.fetchStoriesForUser(user.id!).then((hasStories) {
        userHasStories[user.id!] = hasStories;
      });
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

      await toggleLikeUsecase.execute(currentUser!.id ?? 0, isFavorite.value);

      if (isFavorite.value) {
        showSuccessSnackbar('¡Te gusta ${profile.value.name}!');
      } else {
        showInfoSnackbar('${profile.value.name} removido de favoritos');
      }

      if (isFavorite.value) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          nextUser();
        });
      }
    } catch (e) {
      isFavorite.value = previousState;
      showErrorSnackbar('Error al procesar: ${cleanExceptionMessage(e)}');
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

      Future.delayed(const Duration(milliseconds: 1000), () {
        nextUser();
      });
    } catch (e) {
      showErrorSnackbar('Error al dar like: ${cleanExceptionMessage(e)}');
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
    } finally {
      isProcessingLike.value = false;
    }
  }

  void sendMessage() => sendLike();

  void sendSuperLike() {
    showInfoSnackbar('Le has enviado un Super Like a ${profile.value.name}');
    Future.delayed(const Duration(milliseconds: 1000), () {
      nextUser();
    });
  }

  void skipUser() => rejectUser();

  void blockUser() {
    if (Get.context == null) return;
    showCustomAlert(
      context: Get.context!,
      title: 'Bloquear usuario',
      message:
          '¿Estás seguro de que quieres bloquear a ${profile.value.name}?',
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
      Future.delayed(const Duration(milliseconds: 1500), () => Get.back());
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
    showWarningSnackbar(
      'Gracias por tu reporte. Revisaremos el perfil de ${profile.value.name}',
    );
  }

  // ─────────────────────────────────────────────
  //  PREVIEW DIALOG – con soporte de historias
  // ─────────────────────────────────────────────
void showUserPreviewDialog(GetUserEntity user, int userIndex) {
    currentUserIndex.value = userIndex;
    updateCurrentProfile();

    final gallery = _buildGallery(user);
    final RxInt previewIndex = 0.obs;
    final PageController previewPageController = PageController();

    // Verificar si el usuario tiene historias (puede venir del cache previo)
    final storyController = Get.find<StoryController>();
    final RxBool hasStories = (userHasStories[user.id] == true).obs;

    // Si aún no lo sabemos, consultamos en tiempo real
    if (user.id != null && !userHasStories.containsKey(user.id)) {
      storyController.fetchStoriesForUser(user.id!).then((result) {
        userHasStories[user.id!] = result;
        hasStories.value = result;
      });
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: ThemeColor.backgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Galería de fotos ──
                SizedBox(
                  height: 320,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: previewPageController,
                        itemCount: gallery.length,
                        onPageChanged: (i) => previewIndex.value = i,
                        itemBuilder: (_, i) {
                          final url = gallery[i];
                          if (url.isEmpty) {
                            return Container(
                              color: ThemeColor.backgroundColorfondo,
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: ThemeColor.textSecondaryColor,
                              ),
                            );
                          }
                          return CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: ThemeColor.backgroundColorfondo,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ThemeColor.primaryColor,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: ThemeColor.backgroundColorfondo,
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: ThemeColor.textSecondaryColor,
                              ),
                            ),
                          );
                        },
                      ),

                      // Indicadores de página — se suben para no chocar con el botón
                      if (gallery.length > 1)
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: Obx(
                            () => Row(
                              children: List.generate(gallery.length, (i) {
                                return Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        right: i < gallery.length - 1 ? 4 : 0),
                                    height: 3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: previewIndex.value == i
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),

                      // Gradiente info abajo
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${user.name ?? 'Usuario'}, ${user.age ?? 0}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (user.city != null &&
                                        user.city!.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            user.city!,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),


Obx(() {
  if (!hasStories.value) return const SizedBox.shrink();

  return GestureDetector(
    onTap: () {
      Get.back(); 
      if (Get.context != null) {
        showTargetUserStoryModal(
          Get.context!,
          userId: user.id!,
          userName: user.name ?? 'Usuario',
          userPhoto: user.fotoUrl,
        );
      }
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFE040FB), Color(0xFFFF6D00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            padding: const EdgeInsets.all(1.5),
            child: ClipOval(
              child: user.fotoUrl != null && user.fotoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: user.fotoUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 24,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 24,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white54,
                        size: 24,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Historia',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Info + botones ──
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bio
                      if (user.bio != null &&
                          user.bio!.isNotEmpty &&
                          double.tryParse(user.bio!) == null) ...[
                        Text(
                          user.bio!,
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textTertiaryColor,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Status
                      if (user.status != null && user.status!.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 70),
                          margin: const EdgeInsets.only(bottom: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                ThemeColor.backgroundColor.withOpacity(0.92),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                              bottomLeft: Radius.circular(2),
                            ),
                            border: Border.all(
                              color:
                                  ThemeColor.radarScanner.withOpacity(0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    ThemeColor.radarScanner.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            user.status!,
                            style: TextStyle(
                              color: ThemeColor.radarScanner,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Intereses (máx 3)
                      if (user.interestsIds != null &&
                          user.interestsIds!.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: user.interestsIds!
                              .take(3)
                              .map(
                                (i) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: ThemeColor.primaryColor
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    i.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: ThemeColor.textPrimaryColor,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Botón IR AL CHAT
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                            Get.toNamed(
                              RoutesNames.chatPage,
                              arguments: {
                                'userid': user.id,
                                'name': user.name ?? 'Usuario',
                              },
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline,
                              color: Colors.white),
                          label: const Text(
                            'Enviar mensaje',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Botón ver perfil completo
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back();
                            Get.toNamed(
                              RoutesNames.userProfileDetailPage,
                              arguments: {'userId': user.id},
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color:
                                  ThemeColor.primaryColor.withOpacity(0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Ver perfil completo',
                            style: TextStyle(
                              color: ThemeColor.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // ── Avatar del radar con anillo de historia ──
  // Reemplaza el widget del avatar en tu radar/lista con este:
  Widget buildUserAvatarWithStory({
    required GetUserEntity user,
    required VoidCallback onTapAvatar,
    required VoidCallback onTapStory,
  }) {
    final bool allViewed = false; // ajusta con tu lógica de vistas
    final bool hasStory = userHasStories[user.id] == true;

    return GestureDetector(
      onTap: hasStory ? onTapStory : onTapAvatar,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasStory && !allViewed
              ? const LinearGradient(
                  colors: [Color(0xFFE040FB), Color(0xFFFF6D00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: (!hasStory || allViewed)
              ? Border.all(color: Colors.white54, width: 2)
              : null,
        ),
        padding: const EdgeInsets.all(2),
        child: ClipOval(
          child: user.fotoUrl != null && user.fotoUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: user.fotoUrl!,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
        ),
      ),
    );
  }
}