import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/user/presentation/controller/user_profile_controller.dart';

class UserProfileDetailPage extends StatelessWidget {
  const UserProfileDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserProfileController>();

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

      if (controller.currentUser.value == null) {
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
                  Icons.person_off_outlined,
                  size: 80,
                  color: ThemeColor.textSecondaryColor,
                ),
                SizedBox(height: 16),
                Text('Usuario no encontrado', style: ThemeColor.headingMedium),
                SizedBox(height: 8),
                Text(
                  'No se pudo cargar el perfil',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Volver'),
                ),
              ],
            ),
          ),
        );
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          FocusScope.of(Get.context!).unfocus();
          if (controller.goPerfilIndex.value >= 0) {
            Get.offAllNamed(
              RoutesNames.homePage,
              arguments: {'tab': controller.goPerfilIndex.value},
            );
          } else {
            Get.back();
          }
        },
        child: Scaffold(
          backgroundColor: ThemeColor.backgroundColorfondo,
          body: Column(
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
                          FocusScope.of(Get.context!).unfocus();

                          if (controller.goPerfilIndex.value >= 0) {
                            Get.offAllNamed(
                              RoutesNames.homePage,
                              arguments: {
                                'tab': controller.goPerfilIndex.value,
                              },
                            );
                          } else {
                            Get.back();
                          }
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
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildBioSection(controller),
                          const SizedBox(height: 16),
                          _buildBuscoSection(controller),
                          const SizedBox(height: 16),
                          if (controller.userQualities.isNotEmpty)
                            _buildQualitiesSection(controller),
                          const SizedBox(height: 16),
                          if (controller.userInterests.isNotEmpty)
                            _buildInterestsSection(controller),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildReporteButtons(controller),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSliverAppBar(UserProfileController controller) {
    return Obx(
      () => SliverAppBar(
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
                    itemCount: controller.userGallery.length,
                    itemBuilder: (context, index) {
                      final imageUrl = controller.userGallery[index];

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

                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: ThemeColor.backgroundColorfondo,
                          child: Icon(
                            Icons.person,
                            size: 100,
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: ThemeColor.backgroundColorfondo,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                    : null,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ThemeColor.primaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  if (controller.userGallery.length > 1)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: List.generate(
                          controller.userGallery.length,
                          (index) => Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                right: index < controller.userGallery.length - 1
                                    ? 4
                                    : 0,
                              ),
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color:
                                    controller.currentImageIndex.value == index
                                    ? ThemeColor.cardColor
                                    : ThemeColor.cardColor.withOpacity(0.4),
                                boxShadow: [ThemeColor.lightShadow],
                              ),
                            ),
                          ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${controller.userName}, ${controller.userAge}',
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
                                controller.currentUser.value?.city ??
                                    'Cerca de ti',
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBioSection(UserProfileController controller) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
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
              controller.userBio,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: ThemeColor.textTertiaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscoSection(UserProfileController controller) {
    return Obx(() {
      final pref = controller.currentUser.value?.preferences;
      if (pref == null) return const SizedBox.shrink();

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
                if (pref.connectiontype != null &&
                    pref.connectiontype!.isNotEmpty)
                  _buildPrefChip(Icons.favorite_border, pref.connectiontype!),
                if (pref.searchgender != null && pref.searchgender!.isNotEmpty)
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

  Widget _buildInterestsSection(UserProfileController controller) {
    return Obx(
      () => Container(
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

              children: controller.userInterests
                  .map((i) => _buildChip(i))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualitiesSection(UserProfileController controller) {
    return Obx(
      () => Container(
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
              'Mis Cualidades',
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

              children: controller.userQualities
                  .map((q) => _buildChip(q))
                  .toList(),
            ),
          ],
        ),
      ),
    );
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

Widget _buildReporteButtons(UserProfileController controller) {
  return SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Obx(() {
        final showReject = controller.showRejectButton;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [ 
            if (showReject)
              GestureDetector(
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
              )
            else
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
                    Icons.favorite_rounded,
                    color: ThemeColor.textLightColor,
                    size: 32,
                  ),
                ),
              ),
 
            if (showReject)
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
                    Icons.favorite_rounded,
                    color: ThemeColor.textLightColor,
                    size: 32,
                  ),
                ),
              )
            else
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
        );
      }),
    ),
  );
}
}
