import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/like/domain/entities/pending_chat_entity.dart';
import 'package:tendria/features/like/presentation/controller/liked_by_users_controller.dart';
import 'package:tendria/features/stories/presentation/page/story_controller.dart';
import 'package:tendria/features/stories/presentation/page/target_user_story_modal.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/usecase/fetch_nearby_users_usecase.dart';
import 'package:tendria/features/like/domain/usecase/toggle_like_usecase.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';

class NearbyUsersController extends GetxController {
  final FetchNearbyUsersUsecase fetchNearbyUsersUsecase;
  final ToggleLikeUsecase toggleLikeUsecase;

  NearbyUsersController({
    required this.fetchNearbyUsersUsecase,
    required this.toggleLikeUsecase,
  });
 
  LanguageController get _l => Get.find<LanguageController>();
 

  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxInt currentImageIndex = 0.obs;
  final RxBool isProcessingLike = false.obs;

  final RxList<GetUserEntity> nearbyUsers = <GetUserEntity>[].obs;
  final RxList<GetUserEntity> currentRadarUsers = <GetUserEntity>[].obs;
  final RxInt currentUserIndex = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 6.obs;
  final RxBool noMoreUsers = false.obs;

  final RxMap<int, bool> userHasStories = <int, bool>{}.obs;

  ProfileController get myProfileController => Get.find<ProfileController>();

  late PageController pageController;

  final Rx<GetUserEntity?> currentProfile = Rx<GetUserEntity?>(null);
 

  GetUserEntity? get currentUser {
    if (nearbyUsers.isEmpty || currentUserIndex.value >= nearbyUsers.length) {
      return null;
    }
    return nearbyUsers[currentUserIndex.value];
  }

  List<String> get currentGallery => _buildGallery(currentProfile.value);

  String get currentCity {
    final profile = currentProfile.value;
    if (profile == null || profile.city == null) return '';
    return profile.city!;
  }
 

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
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
    noMoreUsers.value = false ;
    final users = await fetchNearbyUsersUsecase.execute(
      currentPage.value,
      pageSize.value,
    );

    if (users.isEmpty) { 
      nearbyUsers.value = [];
      currentRadarUsers.value = [];
      currentProfile.value = null;
      noMoreUsers.value = true;
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
    _preloadStoryIndicators(users);
  } catch (e) { 
    nearbyUsers.value = [];
    currentRadarUsers.value = [];
    currentProfile.value = null;
    noMoreUsers.value = true;
    showErrorSnackbar(
      '${_l.t('nearby_load_error')}: ${cleanExceptionMessage(e)}',
    );
  } finally {
    isLoading.value = false;
  }
}

  Future<void> loadNextBatch() async {
    currentPage.value++;
    await loadNearbyUsers();
  }

  void _preloadStoryIndicators(List<GetUserEntity> users) {
    final storyController = Get.find<StoryController>();
    for (final user in users) {
      if (user.id == null) continue;
      storyController.fetchStoriesForUser(user.id!).then((hasStories) {
        userHasStories[user.id!] = hasStories;
      });
    }
  }

  void updateCurrentProfile() {
    if (nearbyUsers.isEmpty || currentUserIndex.value >= nearbyUsers.length) {
      return;
    }
    currentProfile.value = nearbyUsers[currentUserIndex.value];
    currentImageIndex.value = 0;
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
    isFavorite.value = false;
  }

  List<String> _buildGallery(GetUserEntity? user) {
    if (user == null) return [''];
    final gallery = <String>[];

    if (user.fotoUrl != null && user.fotoUrl!.isNotEmpty) {
      gallery.add(user.fotoUrl!);
    }

    if (user.assets != null && user.assets!.isNotEmpty) {
      final sorted = user.assets!.toList()
        ..sort((a, b) => a.orden.compareTo(b.orden));
      for (final asset in sorted) {
        if (!gallery.contains(asset.url)) gallery.add(asset.url);
      }
    }

    if (gallery.isEmpty) gallery.add('');
    return gallery;
  }

  void onPageChanged(int index) {
    currentImageIndex.value = index;
  }

  void nextUser() {
    if (currentUserIndex.value < nearbyUsers.length - 1) {
      currentUserIndex.value++;
      updateCurrentProfile();
    } else {
      noMoreUsers.value = true;
    }
  }
 

  Future<void> toggleFavorite() async {
    if (currentUser == null || isProcessingLike.value) return;

    final previousState = isFavorite.value;
    isFavorite.value = !isFavorite.value;

    try {
      isProcessingLike.value = true;

      if (isFavorite.value) {
        showSuccessSnackbar(
          '${_l.t('nearby_liked')} ${currentProfile.value?.name}!',
        );
        Future.delayed(const Duration(milliseconds: 1000), nextUser);
      } else {
        showInfoSnackbar(
          '${currentProfile.value?.name} ${_l.t('nearby_removed_fav')}',
        );
      }
    } catch (e) {
      isFavorite.value = previousState;
      showErrorSnackbar(
        '${_l.t('nearby_error_process')}: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isProcessingLike.value = false;
    }
  }

  Future<void> sendLike() async {
    if (currentUser == null || isProcessingLike.value) return;

    try {
      isProcessingLike.value = true;
      showSuccessSnackbar(
        '${_l.t('nearby_like_sent')} ${currentProfile.value?.name}!',
      );
      Future.delayed(const Duration(milliseconds: 1000), nextUser);
    } catch (e) {
      showErrorSnackbar(
        '${_l.t('nearby_error_like')}: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isProcessingLike.value = false;
    }
  }

  Future<void> rejectUser() async {
    if (currentUser == null || isProcessingLike.value) return;

    try {
      isProcessingLike.value = true;
      showInfoSnackbar(_l.t('nearby_next_profile'));
      nextUser();
    } catch (e) {
      showErrorSnackbar(
        '${_l.t('nearby_error_reject')}: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isProcessingLike.value = false;
    }
  }

  void sendMessage() => sendLike();
  void skipUser() => rejectUser();
 

  void sendMensaje() {
    final user = currentProfile.value;
    if (user == null) return;

    final chat = user.chat;

    if (chat != null && chat.pendingAcepted) {
      final likedByController = Get.find<LikedByUsersController>();
      likedByController.unlockChat(
        PendingChatEntity(
          chatId: chat.id,
          userId: user.id ?? 0,
          name: user.name ?? _l.t('user'),
          photoUrl: user.fotoUrl,
          age: user.age,
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
        arguments: {
          'userid': user.id,
          'name': user.name ?? _l.t('user'),
          'goHomeIndex': 2,
        },
      );
      return;
    }

    Get.toNamed(
      RoutesNames.chatPage,
      arguments: {
        'chatId': chat.id,
        'name': user.name ?? _l.t('user'),
        'goHomeIndex': 2,
      },
    );
  }

  bool get showRejectButton {
    final chat = currentProfile.value?.chat;
    if (chat != null && chat.id != 0) return false;
    return true;
  }
 

  void sendSuperLike() {
    showInfoSnackbar(
      '${_l.t('nearby_superlike_sent')} ${currentProfile.value?.name}',
    );
    Future.delayed(const Duration(milliseconds: 1000), nextUser);
  }
  

  void blockUser() {
    if (Get.context == null) return;
    showCustomAlert(
      context: Get.context!,
      title: _l.t('nearby_block_title'),
      message: '${_l.t('nearby_block_msg')} ${currentProfile.value?.name}?',
      confirmText: _l.t('nearby_block_confirm'),
      cancelText: _l.t('cancel'),
      type: CustomAlertType.warning,
      onConfirm: _confirmBlock,
    );
  }

  void _confirmBlock() {
    final userName = currentProfile.value?.name ?? _l.t('user');
    nearbyUsers.removeAt(currentUserIndex.value);
    currentRadarUsers.removeAt(currentUserIndex.value);

    if (currentUserIndex.value >= nearbyUsers.length) {
      currentUserIndex.value = nearbyUsers.length - 1;
    }

    showErrorSnackbar('$userName ${_l.t('nearby_blocked')}');

    if (nearbyUsers.isEmpty) {
      showWarningSnackbar(_l.t('nearby_all_seen'));
      Future.delayed(const Duration(milliseconds: 1500), () => Get.back());
    } else {
      updateCurrentProfile();
    }
  } 

  void reportUser() {
    if (Get.context == null) return;
    showCustomAlert(
      context: Get.context!,
      title: _l.t('nearby_report_title'),
      message: '${_l.t('nearby_report_msg')} ${currentProfile.value?.name}?',
      confirmText: _l.t('nearby_report_confirm'),
      cancelText: _l.t('cancel'),
      type: CustomAlertType.warning,
      onConfirm: _confirmReport,
    );
  }

  void _confirmReport() {
    showWarningSnackbar(
      '${_l.t('nearby_report_thanks')} ${currentProfile.value?.name}',
    );
  }
 

  void showUserPreviewDialog(GetUserEntity user, int userIndex) {
    currentUserIndex.value = userIndex;
    updateCurrentProfile();

    final gallery = _buildGallery(user);
    final RxInt previewIndex = 0.obs;
    final PageController previewPageController = PageController();

    final storyController = Get.find<StoryController>();
    final RxBool hasStories = (userHasStories[user.id] == true).obs;

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
                            fit: BoxFit.contain,
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
                                      right: i < gallery.length - 1 ? 4 : 0,
                                    ),
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
                                      '${user.name ?? _l.t('user')}, ${user.age ?? 0}',
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
                                if (!hasStories.value) {
                                  return const SizedBox.shrink();
                                }
                                return GestureDetector(
                                  onTap: () {
                                    Get.back();
                                    if (Get.context != null) {
                                      showTargetUserStoryModal(
                                        Get.context!,
                                        userId: user.id!,
                                        userName: user.name ?? _l.t('user'),
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
                                            colors: [
                                              Color(0xFFE040FB),
                                              Color(0xFFFF6D00),
                                            ],
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
                                            child:
                                                user.fotoUrl != null &&
                                                    user.fotoUrl!.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl: user.fotoUrl!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    placeholder: (_, __) =>
                                                        Container(
                                                          color:
                                                              Colors.grey[800],
                                                          child: const Icon(
                                                            Icons.person,
                                                            color:
                                                                Colors.white54,
                                                            size: 24,
                                                          ),
                                                        ),
                                                    errorWidget: (_, __, ___) =>
                                                        Container(
                                                          color:
                                                              Colors.grey[800],
                                                          child: const Icon(
                                                            Icons.person,
                                                            color:
                                                                Colors.white54,
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
                                      Text(
                                        _l.t('stories'),
                                        style: const TextStyle(
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
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
 
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      if (user.status != null && user.status!.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 70),
                          margin: const EdgeInsets.only(bottom: 3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColor.backgroundColor.withOpacity(0.92),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                              bottomLeft: Radius.circular(2),
                            ),
                            border: Border.all(
                              color: ThemeColor.radarScanner.withOpacity(0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeColor.radarScanner.withOpacity(0.2),
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
                                'name': user.name ?? _l.t('user'),
                                'photo': user.fotoUrl,
                                'MyPhoto': myProfileController.profilePhotoUrl,
                                'goPerfilIndex': 1,
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                          ),
                          label: Text(
                            _l.t('nearby_send_message'),
                            style: const TextStyle(
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
                              color: ThemeColor.primaryColor.withOpacity(0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            _l.t('nearby_view_profile'),
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

  Widget buildUserAvatarWithStory({
    required GetUserEntity user,
    required VoidCallback onTapAvatar,
    required VoidCallback onTapStory,
  }) {
    final bool hasStory = userHasStories[user.id] == true;

    return GestureDetector(
      onTap: hasStory ? onTapStory : onTapAvatar,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasStory
              ? const LinearGradient(
                  colors: [Color(0xFFE040FB), Color(0xFFFF6D00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: !hasStory
              ? Border.all(color: Colors.white54, width: 2)
              : null,
        ),
        padding: const EdgeInsets.all(2),
        child: ClipOval(
          child: user.fotoUrl != null && user.fotoUrl!.isNotEmpty
              ? CachedNetworkImage(imageUrl: user.fotoUrl!, fit: BoxFit.cover)
              : Container(
                  color: Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
        ),
      ),
    );
  }
}
