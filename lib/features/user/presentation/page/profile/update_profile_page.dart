import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/controller/updateProfile/update_profile_tutorial_controller.dart';
import 'package:tendria/common/controller/updateProfile/update_profile_tutorial_overlay.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/stories/presentation/page/storyring/my_story_ring_widget.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/presentation/controller/nearby_users_controller.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';
import 'package:tendria/features/user/presentation/controller/update_profile_controller.dart';
import 'package:tendria/features/user/presentation/widget/interests_section_widget.dart';
import 'package:tendria/features/user/presentation/widget/qualities_section_widget.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  late final ProfileController controller;
  late final UpdateProfileTutorialController tutorialCtrl;

  UpdateProfileController get _updater => Get.find<UpdateProfileController>();
  LanguageController get _l => Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    controller   = Get.find<ProfileController>();
    tutorialCtrl = Get.put(UpdateProfileTutorialController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tutorialCtrl.notifyPageReady();
    });
  }

 @override
Widget build(BuildContext context) {
  return Stack(                          // ← Stack envuelve todo
    children: [
      Scaffold(
        backgroundColor: ThemeColor.backgroundColorfondo,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppBar(
            backgroundColor: ThemeColor.backgroundColor,
            elevation: 10,
            shadowColor: ThemeColor.shadowColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: ThemeColor.textDarkColor),
              onPressed: () => Get.back(),
            ),
          ),
        ),
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
                    SizedBox(height: ThemeColor.paddingLarge),
                    Obx(() => _buildEditSection()),
                    SizedBox(height: ThemeColor.paddingExtraLarge),
                    SizedBox(height: ThemeColor.paddingExtraLarge),
                    _buildDeleteAccountButton(),
                    SizedBox(height: ThemeColor.paddingLarge),
                  ],
                ),
              ),
            );
          }),
        ),
      ),

      // ← Overlay encima del Scaffold completo (incluyendo AppBar)
      Obx(
        () => tutorialCtrl.isVisible.value
            ? const UpdateProfileTutorialOverlay()
            : const SizedBox.shrink(),
      ),
    ],
  );
}
  Widget _buildEditSection() {
    return Column(
      children: [
        // ← key en los primeros dos items
        _buildItem(
          key: tutorialCtrl.ageRangeKey,
          _l.t('age_range'),
          () {
            final prefs = controller.userEntity.value?.preferences;
            final min = prefs?.agemin ?? 18;
            final max = prefs?.agemax ?? 80;
            return '$min - $max ${_l.t('years')}';
          },
          onTap: () {
            final prefs = controller.userEntity.value?.preferences;
            _updater.showEditAgeRange(prefs?.agemin ?? 18, prefs?.agemax ?? 80);
          },
        ),
        SizedBox(height: ThemeColor.paddingMedium),
        _buildItem(
          key: tutorialCtrl.maxDistanceKey,
          _l.t('max_distance'),
          () {
            final km =
                controller.userEntity.value?.preferences?.distancekm ?? 50;
            if (km >= 1000) return _l.t('max_distance');
            if (km < 1) return '${(km * 1000).toInt()} m';
            return '${km.toStringAsFixed(km == km.toInt() ? 0 : 1)} km';
          },
          onTap: () {
            final km =
                (controller.userEntity.value?.preferences?.distancekm ?? 50)
                    .toInt();
            _updater.showEditDistance(km);
          },
        ),
        SizedBox(height: ThemeColor.paddingMedium),
        // El resto sin key
        _buildItem(_l.t('height'), () => '${controller.heightcm} cm',
            onTap: () => _updater.showEditHeight(controller.heightcm.toString())),
        SizedBox(height: ThemeColor.paddingMedium),
        _buildItem(_l.t('my_gender'), () => controller.gender,
            onTap: () => _updater.showEditGender(controller.gender)),
        SizedBox(height: ThemeColor.paddingMedium),
        _buildItem(_l.t('language'), () => controller.primarylanguage,
            onTap: () => _updater.showEditLanguage(controller.primarylanguage)),
        SizedBox(height: ThemeColor.paddingMedium),
        _buildItem(_l.t('birth_date'), () => controller.formattedDateOfBirth,
            onTap: () => _updater.showEditDateOfBirth(controller.formattedDateOfBirth)),
        SizedBox(height: ThemeColor.paddingMedium),
        _buildItem(
          _l.t('looking_for'),
          () => controller.userEntity.value?.preferences?.searchgender ?? '',
          onTap: () => _updater.showEditSearchGender(
              controller.userEntity.value?.preferences?.searchgender ?? ''),
        ),
        SizedBox(height: ThemeColor.paddingMedium),
        _buildItem(
          _l.t('connection_type'),
          () => controller.userEntity.value?.preferences?.connectiontype ?? '',
          onTap: () => _updater.showEditConnectionType(
              controller.userEntity.value?.preferences?.connectiontype ?? ''),
        ),
      ],
    );
  }

  Widget _buildItem(
    String title,
    String Function() valueBuilder, {
    Key? key,                         // ← parámetro key opcional
    VoidCallback? onTap,
  }) {
    return Obx(() {
      return GestureDetector(
        key: key,                     // ← asignado aquí
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: ThemeColor.paddingLarge),
          padding: EdgeInsets.all(ThemeColor.paddingLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ThemeColor.largeBorderRadius,
            boxShadow: [ThemeColor.cardShadow],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: ThemeColor.subtitleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.textDarkColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      valueBuilder(),
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textDarkColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: ThemeColor.textSecondaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDeleteAccountButton() {
    return Obx(() {
      final isLoading = _updater.isUpdating.value;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: ThemeColor.paddingLarge),
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : _updater.confirmDeleteAccount,
          icon: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeColor.errorColor,
                    ),
                  ),
                )
              : Icon(Icons.delete_forever, color: ThemeColor.errorColor),
          label: Text(
            _l.t('delete_account'),
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: ThemeColor.paddingMedium),
            side: BorderSide(color: ThemeColor.errorColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: ThemeColor.largeBorderRadius,
            ),
          ),
        ),
      );
    });
  }
}