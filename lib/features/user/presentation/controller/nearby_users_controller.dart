import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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
import 'package:tendria/features/user/domain/entities/create_reports_user_entity.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/entities/update_location_entity.dart';
import 'package:tendria/features/user/domain/usecase/create_reports_user_usecase.dart';
import 'package:tendria/features/user/domain/usecase/fetch_nearby_users_usecase.dart';
import 'package:tendria/features/like/domain/usecase/toggle_like_usecase.dart';
import 'package:tendria/features/user/domain/usecase/update_location_usecase.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';

class NearbyUsersController extends GetxController with WidgetsBindingObserver {
  final FetchNearbyUsersUsecase fetchNearbyUsersUsecase;
  final ToggleLikeUsecase toggleLikeUsecase;
  final UpdateLocationUsecase updateLocationUsecase;
  final CreateReportsUserUsecase createReportsUserUsecase;

  NearbyUsersController({
    required this.fetchNearbyUsersUsecase,
    required this.toggleLikeUsecase,
    required this.updateLocationUsecase,
    required this.createReportsUserUsecase,
  });

  LanguageController get _l => Get.find<LanguageController>();
  final RxBool locationPermissionDenied = false.obs;

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
  

  bool get alreadyInteracted {
    final like = currentProfile.value?.likeStatus;
    if (like == null) return false;
    return like.id1DioLikeAId2 || like.id2DioLikeAId1;
  }

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
    WidgetsBinding.instance.addObserver(this);
    pageController = PageController();
    loadNearbyUsers();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    pageController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionOnResume();
    }
  }

  Future<void> _checkPermissionOnResume() async {
    final permission = await Geolocator.checkPermission();
    final hasPermission =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    if (!hasPermission) {
      locationPermissionDenied.value = true;
      nearbyUsers.value = [];
      currentRadarUsers.value = [];
      currentProfile.value = null;
    } else if (locationPermissionDenied.value) {
      locationPermissionDenied.value = false;
      await _updateUserLocation();

      currentPage.value = 1;
      await loadNearbyUsers();
    }
  }

  Future<void> _updateUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = _resolveCity(place);
        final country = place.country?.trim() ?? '';

        if (city.isNotEmpty) {
          await updateLocationUsecase.execute(
            UpdateLocationEntity(
              latitude: position.latitude,
              longitude: position.longitude,
              city: city,
              country: country,
            ),
          );
          print('✅ Ubicación actualizada: $city, $country');
        }
      }
    } catch (e) {
      print('⚠️ Error actualizando ubicación en resume: $e');
    }
  }

  String _resolveCity(Placemark place) {
    final subAdmin = place.subAdministrativeArea?.trim() ?? '';
    final locality = place.locality?.trim() ?? '';

    if (subAdmin.isNotEmpty &&
        (subAdmin.contains(' ') || subAdmin.length > 6)) {
      return subAdmin;
    }
    if (locality.isNotEmpty &&
        (locality.contains(' ') || locality.length > 6)) {
      return locality;
    }
    return subAdmin.isNotEmpty ? subAdmin : locality;
  }

  Future<bool> checkLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('📍 Servicio de ubicación deshabilitado');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print('📍 Geolocator permission status: $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('📍 Geolocator permission after request: $permission');
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<void> reloadFromStart() async {
    currentPage.value = 1;
    await loadNearbyUsers();
  }

  Future<void> retryAfterPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      locationPermissionDenied.value = false;
      currentPage.value = 1;
      await loadNearbyUsers();
    }
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  Future<void> loadNearbyUsers() async {
    try {
      isLoading.value = true;
      noMoreUsers.value = false;
      locationPermissionDenied.value = false;

      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        locationPermissionDenied.value = true;
        return;
      }
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
      // showErrorSnackbar(    '${_l.t('nearby_load_error')}: ${cleanExceptionMessage(e)}', );
    } finally {
      isLoading.value = false;
    }
  }

  void reportAndBlockUser() {
    if (Get.context == null) return;
    _showReportBottomSheet(Get.context!, alsoBlock: true);
  }

  void reportUser() {
    if (Get.context == null) return;
    _showReportBottomSheet(Get.context!);
  }

  void _showReportBottomSheet(BuildContext context, {bool alsoBlock = false}) {
    final reasons = [
      _l.t('report_harassment'),
      _l.t('report_inappropriate'),
      _l.t('report_fake'),
      _l.t('report_offensive'),
      _l.t('report_minor'),
      _l.t('report_other'),
    ];

    final selectedReason = RxnString();
    final descController = TextEditingController();
    final shouldBlock = alsoBlock.obs;
    final descError = false.obs;
    final userName = (currentProfile.value?.name ?? _l.t('user'))
        .split(' ')
        .first;

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: ThemeColor.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Obx(
            () => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ThemeColor.subtleBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_l.t('report_title')} $userName',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _l.t('report_select_reason'),
                    style: TextStyle(
                      fontSize: 13,
                      color: ThemeColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...reasons.map(
                    (reason) => GestureDetector(
                      onTap: () => selectedReason.value = reason,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedReason.value == reason
                                ? ThemeColor.primaryColor
                                : ThemeColor.subtleBorder,
                            width: selectedReason.value == reason ? 1.5 : 1,
                          ),
                          color: selectedReason.value == reason
                              ? ThemeColor.primaryColor.withOpacity(0.06)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedReason.value == reason
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: 18,
                              color: selectedReason.value == reason
                                  ? ThemeColor.primaryColor
                                  : ThemeColor.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              reason,
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColor.textPrimary,
                                fontWeight: selectedReason.value == reason
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    onChanged: (_) => descError.value = false,
                    maxLines: 3,
                    maxLength: 300,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColor.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: _l.t('report_desc_hint'),
                      hintStyle: TextStyle(
                        color: ThemeColor.textSecondary,
                        fontSize: 13,
                      ),
                      errorText: descError.value
                          ? _l.t('report_desc_required')
                          : null,
                      filled: true,
                      fillColor: ThemeColor.backgroundColorfondo,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ThemeColor.subtleBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ThemeColor.subtleBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ThemeColor.primaryColor),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ThemeColor.errorColor),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ThemeColor.errorColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (alsoBlock)
                    GestureDetector(
                      onTap: () => shouldBlock.value = !shouldBlock.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: shouldBlock.value
                                ? Colors.red.shade400
                                : ThemeColor.subtleBorder,
                            width: shouldBlock.value ? 1.5 : 1,
                          ),
                          color: shouldBlock.value
                              ? Colors.red.withOpacity(0.06)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              shouldBlock.value
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 20,
                              color: shouldBlock.value
                                  ? Colors.red.shade400
                                  : ThemeColor.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_l.t('report_also_block')} $userName',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ThemeColor.textPrimary,
                                    fontWeight: shouldBlock.value
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  _l.t('report_block_hint'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ThemeColor.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedReason.value == null
                          ? null
                          : () {
                              if (descController.text.trim().isEmpty) {
                                descError.value = true;
                                return;
                              }
                              descError.value = false;
                              _confirmReport(
                                selectedReason.value!,
                                descController.text.trim(),
                                alsoBlock: shouldBlock.value,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: shouldBlock.value
                            ? Colors.red.shade600
                            : ThemeColor.primaryColor,
                        disabledBackgroundColor: ThemeColor.subtleBorder,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        shouldBlock.value
                            ? _l.t('report_send_and_block')
                            : _l.t('report_send'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReport(
    String reason,
    String description, {
    bool alsoBlock = false,
  }) async {
    final userId = currentProfile.value?.id ?? 0;
    final userName = (currentProfile.value?.name ?? _l.t('user'))
        .split(' ')
        .first;
    try {
      Get.back();
      await createReportsUserUsecase(
        CreateReportsUserEntity(
          reportedid: userId,
          reason: reason,
          description: description,
        ),
      );
      if (alsoBlock) {
        _confirmBlock();
        showSuccessSnackbar('$userName ${_l.t('report_block_success')}');
      } else {
        showSuccessSnackbar('${_l.t('report_success')} $userName');
      }
    } catch (e) {
      showErrorSnackbar('${_l.t('error')}: ${cleanExceptionMessage(e)}');
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
      await toggleLikeUsecase.execute(currentProfile.value!.id ?? 0, true);
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
      print(' use id ${currentProfile.value!.id}');
      await toggleLikeUsecase.execute(currentProfile.value!.id ?? 0, false);
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
            color: ThemeColor.backgroundColorfondo,
            child: SingleChildScrollView(           
    child:Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: PageView.builder(
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
                        ),
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

                      // Botón cerrar
                      Positioned(
                        top: 10,
                        right: 10,
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

                      // Story avatar
                      Obx(() {
                        if (!hasStories.value) return const SizedBox.shrink();
                        return Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
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
                                  width: 50,
                                  height: 50,
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
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ThemeColor.backgroundColor,
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
                                              placeholder: (_, __) => Container(
                                                color: ThemeColor
                                                    .backgroundColorfondo,
                                                child: const Icon(
                                                  Icons.person,
                                                  color: Colors.white54,
                                                  size: 20,
                                                ),
                                              ),
                                              errorWidget: (_, __, ___) =>
                                                  Container(
                                                    color: ThemeColor
                                                        .backgroundColorfondo,
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Colors.white54,
                                                      size: 20,
                                                    ),
                                                  ),
                                            )
                                          : Container(
                                              color: ThemeColor
                                                  .backgroundColorfondo,
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white54,
                                                size: 20,
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
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.name ?? _l.t('user')}, ${user.age ?? 0}.',
                        style: ThemeColor.headingMedium.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (user.status != null && user.status!.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 120),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
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
                              color: ThemeColor.colorstatus.withOpacity(0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeColor.colorstatus.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            user.status!,
                            style: TextStyle(
                              color: ThemeColor.colorstatus,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Bio
                      if (user.bio != null &&
                          user.bio!.isNotEmpty &&
                          double.tryParse(user.bio!) == null) ...[
                        Text(
                          user.bio!,
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textTertiaryColor,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Ciudad
                      if (user.city != null && user.city!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 15,
                                color: ThemeColor.textSecondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.city!,
                                style: TextStyle(
                                  color: ThemeColor.textSecondaryColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Botón Chat (primario)
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

                      // Botón Ver perfil (secundario)
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
              ],),
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
