import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/user/presentation/controller/nearby_users_controller.dart';

class NearbyUsersPage extends StatelessWidget {
  const NearbyUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NearbyUsersController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: ThemeColor.backgroundColorfondo,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeColor.primaryColor,
              ),
            ),
          ),
        );
      }

      if (controller.nearbyUsers.isEmpty) {
        return Scaffold(
          backgroundColor: ThemeColor.backgroundColorfondo,
          appBar: AppBar(
            backgroundColor: ThemeColor.backgroundColorfondo,
            elevation: 0,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: ThemeColor.textSecondaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay usuarios disponibles',
                  style: ThemeColor.headingMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Intenta más tarde',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.loadNearbyUsers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recargar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

return Scaffold(
  backgroundColor: ThemeColor.backgroundColorfondo,
  body: Obx(() {
  if (controller.noMoreUsers.value || 
    (!controller.isLoading.value && controller.nearbyUsers.isEmpty)) {
      return _buildNoMoreUsersState(controller);
    }

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: ThemeColor.backgroundColorfondo,
                elevation: 4,
                shadowColor: ThemeColor.shadowColor,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Get.offAllNamed(
                      RoutesNames.radarScannerPage,
                    );
                  },
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/logo/logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ],
                ),
              ),
              _buildSliverAppBar(controller),
              SliverToBoxAdapter(
                child: Obx(() {
                  final user = controller.currentProfile.value;
                  if (user == null) return const SizedBox.shrink();

                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildBioSection(controller),
                      const SizedBox(height: 16),
                      _buildBuscoSection(controller),
                      const SizedBox(height: 16),
                      if (user.qualitiesIds != null &&
                          user.qualitiesIds!.isNotEmpty)
                        _buildQualitiesSection(controller),
                      const SizedBox(height: 16),
                      if (user.interestsIds != null &&
                          user.interestsIds!.isNotEmpty)
                        _buildInterestsSection(controller),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
        _buildReporteButtons(controller),
      ],
    );
  }),
);
    });
  }

Widget _buildNoMoreUsersState(NearbyUsersController controller) {
  final l = Get.find<LanguageController>();
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 72,
              color: ThemeColor.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.t('no_more_profiles'),
            style: ThemeColor.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l.t('no_more_profiles_desc'),
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.textSecondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(RoutesNames.updateProfilePage),
              icon: const Icon(Icons.tune_rounded, color: Colors.white),
              label: Text(
                l.t('modify_preferences'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                controller.noMoreUsers.value = false;
                controller.loadNearbyUsers();
              },
              icon: Icon(Icons.refresh_rounded, color: ThemeColor.primaryColor),
              label: Text(
                l.t('try_again'),
                style: TextStyle(
                  color: ThemeColor.primaryColor,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: ThemeColor.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildReporteButtons(NearbyUsersController controller) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => controller.showRejectButton
                  ? GestureDetector(
                      onTap: controller.rejectUser,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ThemeColor.textSecondaryColor,
                              ThemeColor.textSecondaryColor.withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColor.textSecondaryColor.withOpacity(
                                0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: ThemeColor.textLightColor,
                          size: 32,
                        ),
                      ),
                    )
                  : const SizedBox(width: 64),
            ),
            GestureDetector(
              onTap: controller.sendMensaje,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeColor.primaryColor,
                      ThemeColor.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColor.primaryColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.message,
                  color: ThemeColor.textLightColor,
                  size: 32,
                ),
              ),
            ),

            GestureDetector(
              onTap: controller.blockUser,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade700, Colors.red.shade400],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.block_rounded,
                  color: ThemeColor.textLightColor,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(NearbyUsersController controller) {
    return Obx(() {
      final user = controller.currentProfile.value;
      if (user == null)
        return const SliverToBoxAdapter(child: SizedBox.shrink());

      final gallery = controller.currentGallery;

      return SliverAppBar(
        automaticallyImplyLeading: false,
        expandedHeight: 450,
        pinned: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: FlexibleSpaceBar(
          background: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: gallery.length,
                    itemBuilder: (context, index) {
                      final imageUrl = gallery[index];
                      if (imageUrl.isEmpty) {
                        return Container(
                          color: ThemeColor.backgroundColorfondo,
                          child: Icon(
                            Icons.person,
                            size: 100,
                            color: ThemeColor.textSecondaryColor,
                          ),
                        );
                      }
                      return CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: ThemeColor.backgroundColorfondo,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ThemeColor.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: ThemeColor.backgroundColorfondo,
                          child: Icon(
                            Icons.person,
                            size: 100,
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      );
                    },
                  ),

                  if (gallery.length > 1)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Obx(
                        () => Row(
                          children: List.generate(gallery.length, (index) {
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: index < gallery.length - 1 ? 4 : 0,
                                ),
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color:
                                      controller.currentImageIndex.value ==
                                          index
                                      ? ThemeColor.cardColor
                                      : ThemeColor.cardColor.withOpacity(0.4),
                                  boxShadow: [ThemeColor.lightShadow],
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeColor.tertiaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(ThemeColor.largeRadius),
                          bottomRight: Radius.circular(ThemeColor.largeRadius),
                        ),
                        boxShadow: [ThemeColor.lightShadow],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.name ?? 'Usuario'}, ${user.age ?? 0}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.textLightColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: ThemeColor.textLightColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      controller.currentCity,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ThemeColor.textLightColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBioSection(NearbyUsersController controller) {
    return Obx(() {
      final bio = controller.currentProfile.value?.bio ?? '';
      if (bio.isEmpty || double.tryParse(bio) != null)
        return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          borderRadius: ThemeColor.mediumBorderRadius,
          boxShadow: [ThemeColor.lightShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mi Bio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColor.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bio,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: ThemeColor.textTertiaryColor,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBuscoSection(NearbyUsersController controller) {
    return Obx(() {
      final pref = controller.currentProfile.value?.preferences;
      if (pref == null) return const SizedBox.shrink();

      final hasContent =
          (pref.connectiontype?.isNotEmpty == true) ||
          (pref.searchgender?.isNotEmpty == true) ||
          (pref.agemin != null && pref.agemax != null);
      if (!hasContent) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          borderRadius: ThemeColor.mediumBorderRadius,
          boxShadow: [ThemeColor.lightShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Busco',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColor.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (pref.connectiontype?.isNotEmpty == true)
                  _buildPrefChip(Icons.favorite_border, pref.connectiontype!),
                if (pref.searchgender?.isNotEmpty == true)
                  _buildPrefChip(Icons.people_outline, pref.searchgender!),
                if (pref.agemin != null && pref.agemax != null)
                  _buildPrefChip(
                    Icons.cake_outlined,
                    '${pref.agemin} - ${pref.agemax} años',
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPrefChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColor.primaryColor.withOpacity(0.5)),
        color: ThemeColor.primaryColor.withOpacity(0.05),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ThemeColor.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: ThemeColor.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(NearbyUsersController controller) {
    return Obx(() {
      final interests = controller.currentProfile.value?.interestsIds;
      if (interests == null || interests.isEmpty)
        return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          borderRadius: ThemeColor.mediumBorderRadius,
          boxShadow: [ThemeColor.lightShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intereses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColor.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests.map((i) => _buildChip(i.name)).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQualitiesSection(NearbyUsersController controller) {
    return Obx(() {
      final qualities = controller.currentProfile.value?.qualitiesIds;
      if (qualities == null || qualities.isEmpty)
        return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          borderRadius: ThemeColor.mediumBorderRadius,
          boxShadow: [ThemeColor.lightShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis cualidades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColor.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: qualities.map((q) => _buildChip(q.name)).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColor.textPrimaryColor, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: ThemeColor.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(NearbyUsersController controller) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: controller.skipUser,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeColor.textSecondaryColor,
                      ThemeColor.textSecondaryColor.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColor.textSecondaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: ThemeColor.textLightColor,
                  size: 32,
                ),
              ),
            ),

            Obx(
              () => GestureDetector(
                onTap: controller.toggleFavorite,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: controller.isFavorite.value
                          ? [
                              ThemeColor.errorColor,
                              ThemeColor.errorColor.withOpacity(0.8),
                            ]
                          : [
                              ThemeColor.primaryColor,
                              ThemeColor.primaryColor.withOpacity(0.8),
                            ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (controller.isFavorite.value
                                    ? ThemeColor.errorColor
                                    : ThemeColor.primaryColor)
                                .withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    controller.isFavorite.value
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: ThemeColor.textLightColor,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
