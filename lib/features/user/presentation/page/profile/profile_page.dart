import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/stories/presentation/page/storyring/my_story_ring_widget.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/presentation/controller/balance_controller.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';
import 'package:tendria/features/user/presentation/controller/update_profile_controller.dart';
import 'package:tendria/features/user/presentation/widget/interests_section_widget.dart';
import 'package:tendria/features/user/presentation/widget/qualities_section_widget.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({Key? key}) : super(key: key);

  UpdateProfileController get _updater => Get.find<UpdateProfileController>();
  BalanceController get _balanceController => Get.find<BalanceController>();

  LanguageController get _l => Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColorfondo,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.userEntity.value == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeColor.primaryColor,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadUserProfile,
            color: ThemeColor.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: ThemeColor.paddingLarge),
                  //    _buildNearbyProfilesButton(),
                  SizedBox(height: ThemeColor.paddingLarge),
                  _buildPhotosSection(),
                  SizedBox(height: ThemeColor.paddingLarge),
                  _buildBiographySection(),
                  SizedBox(height: ThemeColor.paddingLarge),
                  InterestsSectionWidget(isEditable: true),
                  SizedBox(height: ThemeColor.paddingLarge),
                  QualitiesSectionWidget(isEditable: true),
                  SizedBox(height: ThemeColor.paddingExtraLarge),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ThemeColor.paddingLarge),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _l.t('profile'),
                  style: ThemeColor.headingLarge.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.textDarkColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.person_off,
                      color: ThemeColor.textDarkColor,
                    ),
                    onPressed: controller.onViewBlockedUsers,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none,
                      color: ThemeColor.textDarkColor,
                    ),
                    onPressed: controller.onViewNotifications,
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: ThemeColor.textDarkColor),
                    onPressed: controller.onHelpTap,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: ThemeColor.textDarkColor,
                    ),
                    onPressed: controller.onSettingsTap,
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: ThemeColor.paddingLarge),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  MyStoryRingWidget(size: 80),
                  SizedBox(height: ThemeColor.paddingSmall),
                ],
              ),

              SizedBox(width: ThemeColor.paddingLarge),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: ThemeColor.paddingSmall),
                  child: Obx(() {
                    final status = controller.userEntity.value?.status ?? '';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (status.isNotEmpty)
                          GestureDetector(
                            onTap: () => _updater.showEditStatus(status),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeColor.primaryColor.withOpacity(
                                  0.12,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                  bottomLeft: Radius.circular(4),
                                ),
                                border: Border.all(
                                  color: ThemeColor.primaryColor.withOpacity(
                                    0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      status,
                                      style: ThemeColor.bodySmall.copyWith(
                                        color: ThemeColor.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.edit,
                                    size: 12,
                                    color: ThemeColor.primaryColor.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (status.isEmpty)
                          GestureDetector(
                            onTap: () => _updater.showEditStatus(''),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                  bottomLeft: Radius.circular(4),
                                ),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 13,
                                    color: ThemeColor.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _l.t('add_status'),
                                    style: ThemeColor.bodySmall.copyWith(
                                      color: ThemeColor.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        Text(
                          '${controller.userName}, ${controller.userAge}',
                          style: ThemeColor.headingMedium.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: ThemeColor.textDarkColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        GestureDetector(
                          onTap: () =>
                              Get.offAllNamed(RoutesNames.purchasePage),
                          child: Text(
                            '\$ ${_balanceController.currentBalance} MXN',
                            style: ThemeColor.headingMedium.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: ThemeColor.textDarkColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyProfilesButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ThemeColor.paddingLarge),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Get.offAllNamed(RoutesNames.preferencesPage),
        icon: Icon(Icons.radar, size: 24, color: ThemeColor.textLightColor),
        label: Text(
          _l.t('discover'),
          style: ThemeColor.buttonText.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.tertiaryColor,
          foregroundColor: ThemeColor.textLightColor,
          padding: EdgeInsets.symmetric(
            vertical: ThemeColor.paddingMedium + 4,
            horizontal: ThemeColor.paddingLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: ThemeColor.mediumBorderRadius,
          ),
          elevation: 2,
          shadowColor: ThemeColor.tertiaryColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ThemeColor.paddingLarge),
      padding: EdgeInsets.all(ThemeColor.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ThemeColor.largeBorderRadius,
        boxShadow: [ThemeColor.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final count = controller.assets.length;
            final max = controller.maxPhotos;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _l.t('photos'),
                  style: ThemeColor.subtitleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.textDarkColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: count < max
                        ? ThemeColor.primaryColor.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count / $max',
                    style: ThemeColor.bodySmall.copyWith(
                      color: count < max
                          ? ThemeColor.primaryColor
                          : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: ThemeColor.paddingSmall),
          Text(
            _l.t('photos_hint'),
            style: ThemeColor.bodySmall.copyWith(
              color: ThemeColor.textSecondaryColor,
            ),
          ),
          SizedBox(height: ThemeColor.paddingMedium),

          Obx(() {
            final photosCount = controller.assets.length;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: ThemeColor.paddingSmall,
                mainAxisSpacing: ThemeColor.paddingSmall,
                childAspectRatio: 1,
              ),
              itemCount: controller.maxPhotos,
              itemBuilder: (context, index) {
                if (index < photosCount) {
                  return _buildPhotoItem(controller.assets[index]);
                } else {
                  return _buildAddPhotoButton();
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(AssetEntity asset) {
    return Obx(() {
      final isDeleting = controller.isDeletingPhoto.value;

      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: ThemeColor.mediumBorderRadius,
              border: Border.all(color: ThemeColor.dividerColor, width: 1),
            ),
            child: ClipRRect(
              borderRadius: ThemeColor.mediumBorderRadius,
              child: CachedNetworkImage(
                // 👈 reemplaza Image.network
                imageUrl: asset.url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeColor.primaryColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: ThemeColor.backgroundColorfondo,
                  child: Icon(
                    Icons.broken_image,
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: isDeleting
                  ? null
                  : () => controller.confirmDeletePhoto(asset.id),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: isDeleting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAddPhotoButton() {
    return Obx(() {
      final isUploading = controller.isUploadingPhoto.value;

      return GestureDetector(
        onTap: isUploading ? null : controller.addPhoto,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ThemeColor.mediumBorderRadius,
            border: Border.all(color: ThemeColor.dividerColor, width: 1),
          ),
          child: isUploading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeColor.primaryColor,
                      ),
                    ),
                  ),
                )
              : Icon(Icons.add, color: ThemeColor.textSecondaryColor, size: 32),
        ),
      );
    });
  }

  Widget _buildBiographySection() {
    return Obx(() {
      final bio = controller.profileBio;

      if (bio.isEmpty) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => _updater.showEditBio(bio),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: ThemeColor.paddingLarge),
          padding: EdgeInsets.all(ThemeColor.paddingLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ThemeColor.largeBorderRadius,
            boxShadow: [ThemeColor.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _l.t('my_biography'),
                      style: ThemeColor.subtitleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.textDarkColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: ThemeColor.textSecondaryColor,
                  ),
                ],
              ),
              SizedBox(height: ThemeColor.paddingSmall),
              Text(
                bio,
                style: ThemeColor.bodyMedium.copyWith(
                  color: ThemeColor.textDarkColor,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }
}
