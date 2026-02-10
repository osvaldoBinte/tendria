import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/user/presentation/controller/nearby_users_controller.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({Key? key}) : super(key: key);

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
                SizedBox(height: 16),
                Text(
                  'No hay usuarios disponibles',
                  style: ThemeColor.headingMedium,
                ),
                SizedBox(height: 8),
                Text(
                  'Intenta más tarde',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.loadNearbyUsers,
                  icon: Icon(Icons.refresh),
                  label: Text('Recargar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
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
                   // automaticallyImplyLeading: false,
                    pinned: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NUCLEO',
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            color: ThemeColor.textPrimaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            color: ThemeColor.textDarkColor,
                          ),
                          onPressed: () {},
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
                        if (controller.profile.value.interests.isNotEmpty)
                          _buildSobremiSection(controller),
                        const SizedBox(height: 16),
                        if (controller.profile.value.qualities.isNotEmpty)
                          _buildBuscoSection(controller),
                        const SizedBox(height: 16),
                        if (controller.profile.value.interests.isNotEmpty)
                          _buildInterestsSection(controller),
                        const SizedBox(height: 20),
                        _buildReporteButtons(controller),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildActionButtons(controller),
          ],
        ),
      );
    });
  }

  Widget _buildSliverAppBar(NearbyUsersController controller) {
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
                    itemCount: controller.profile.value.gallery.length,
                    itemBuilder: (context, index) {
                      final imageUrl = controller.profile.value.gallery[index];

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
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: ThemeColor.backgroundColorfondo,
                            child: Icon(
                              Icons.person,
                              size: 100,
                              color: ThemeColor.textSecondaryColor,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: ThemeColor.backgroundColorfondo,
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
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

                  if (controller.profile.value.gallery.length > 1)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: List.generate(
                          controller.profile.value.gallery.length,
                          (index) => Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                right:
                                    index <
                                        controller
                                                .profile
                                                .value
                                                .gallery
                                                .length -
                                            1
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${controller.profile.value.name}, ${controller.profile.value.age}',
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
                                      controller.profile.value.distance,
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
                                            ThemeColor.errorColor.withOpacity(
                                              0.8,
                                            ),
                                          ]
                                        : [
                                            ThemeColor.primaryColor,
                                            ThemeColor.primaryColor.withOpacity(
                                              0.8,
                                            ),
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
                                  size: 24,
                                ),
                              ),
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
      ),
    );
  }

  Widget _buildBioSection(NearbyUsersController controller) {
    return Obx(
      () => Container(
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
              controller.profile.value.bio,
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

  Widget _buildSobremiSection(NearbyUsersController controller) {
    return Obx(
      () => Container(
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
              'Sobre mí',
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
              children: controller.profile.value.interests.map((interest) {
                return _buildChip(interest);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsSection(NearbyUsersController controller) {
    return Obx(
      () => Container(
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
              children: controller.profile.value.interests.map((interest) {
                return _buildChip(interest);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscoSection(NearbyUsersController controller) {
    return Obx(
      () => Container(
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
              children: controller.profile.value.qualities.map((quality) {
                return _buildChip(quality);
              }).toList(),
            ),
          ],
        ),
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

  Widget _buildReporteButtons(NearbyUsersController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
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

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ThemeColor.widgetButton(
                    onPressed: controller.blockUser,
                    text: 'Bloquear',
                    backgroundColor: ThemeColor.backgroundColor,
                    borderColor: ThemeColor.tertiaryColor,
                    textColor: ThemeColor.tertiaryColor,
                    fontSize: 15,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    borderRadius: ThemeColor.mediumRadius,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ThemeColor.widgetButton(
                    onPressed: controller.reportUser,
                    text: 'Reportar',
                    backgroundColor: ThemeColor.backgroundColor,
                    borderColor: ThemeColor.tertiaryColor,
                    textColor: ThemeColor.errorColor,
                    fontSize: 15,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    borderRadius: ThemeColor.mediumRadius,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

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
    );
  }

  Widget _buildActionButtons(NearbyUsersController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: ThemeColor.backgroundColor,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ThemeColor.widgetButton(
                onPressed: controller.sendSuperLike,
                text: 'Super Like',
                backgroundColor: ThemeColor.backgroundColor,
                borderColor: ThemeColor.tertiaryColor,
                textColor: ThemeColor.tertiaryColor,
                fontSize: 16,
                padding: const EdgeInsets.symmetric(vertical: 10),
                borderRadius: ThemeColor.smallRadius,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ThemeColor.widgetButton(
                onPressed: controller.sendMessage,
                text: 'Me gusta',
                backgroundColor: ThemeColor.tertiaryColor,
                textColor: ThemeColor.textLightColor,
                fontSize: 16,
                padding: const EdgeInsets.symmetric(vertical: 10),
                borderRadius: ThemeColor.smallRadius,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
