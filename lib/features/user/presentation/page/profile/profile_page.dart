// lib/features/user/presentation/page/profile/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/stories/presentation/page/storyring/my_story_ring_widget.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColorfondo,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.userEntity.value == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.primaryColor),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadUserProfile,
            color: ThemeColor.primaryColor,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: ThemeColor.paddingLarge),
                  _buildPhotosSection(),
                  SizedBox(height: ThemeColor.paddingLarge),
                  _buildBiographySection(),
                  SizedBox(height: ThemeColor.paddingLarge),
                  _buildInterestsSection(),
                  SizedBox(height: ThemeColor.paddingLarge),
                  _buildQualitiesSection(),
                  SizedBox(height: ThemeColor.paddingExtraLarge),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

// ==========================================
// HEADER
// ==========================================

Widget _buildHeader() {
  return Container(
    padding: EdgeInsets.all(ThemeColor.paddingLarge),
    child: Column(
      children: [
        // Barra superior
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Perfil',
              style: ThemeColor.headingLarge.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeColor.textDarkColor,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: ThemeColor.textDarkColor,
                  ),
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
        
        // Foto de perfil y nombre (HORIZONTAL)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna izquierda: Foto + Badge
            Column(
              children: [
                // ⬅️ USAR MyStoryRingWidget
                MyStoryRingWidget(size: 80),
                
                SizedBox(height: ThemeColor.paddingSmall),
                
                // Badge de saldo
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ThemeColor.paddingMedium,
                    vertical: ThemeColor.paddingSmall - 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: ThemeColor.circularBorderRadius,
                    boxShadow: [ThemeColor.lightShadow],
                  ),
                  child: Text(
                    '\$ 250.00 MXN',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textDarkColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(width: ThemeColor.paddingLarge),
            
            // Nombre y edad
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: ThemeColor.paddingSmall),
                child: Obx(() => Text(
                      '${controller.userName}, ${controller.userAge}',
                      style: ThemeColor.headingMedium.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.textDarkColor,
                      ),
                    )),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  // ==========================================
  // SECCIÓN DE FOTOS Y VIDEOS
  // ==========================================
  
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
          Text(
            'Fotos y videos',
            style: ThemeColor.subtitleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: ThemeColor.textDarkColor,
            ),
          ),
          SizedBox(height: ThemeColor.paddingSmall),
          Text(
            'Escoge fotos que muestren tu personalidad',
            style: ThemeColor.bodySmall.copyWith(
              color: ThemeColor.textSecondaryColor,
            ),
          ),
          SizedBox(height: ThemeColor.paddingMedium),
          
          // Grid de fotos
          Obx(() {
            final photosCount = controller.assets.length;
            
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(
          color: ThemeColor.dividerColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: ThemeColor.mediumBorderRadius,
        child: Image.network(
          asset.url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: ThemeColor.backgroundColorfondo,
              child: Icon(
                Icons.broken_image,
                color: ThemeColor.textSecondaryColor,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.primaryColor),
              ),
            );
          },
        ),
      ),
    );
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
            border: Border.all(
              color: ThemeColor.dividerColor,
              width: 1,
            ),
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
              : Icon(
                  Icons.add,
                  color: ThemeColor.textSecondaryColor,
                  size: 32,
                ),
        ),
      );
    });
  }

  Widget _buildBiographySection() {
    return Obx(() {
      final Bio = controller.profileBio;
      
      if (Bio.isEmpty) {
        return SizedBox.shrink();
      }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mi Biografía',
                  style: ThemeColor.subtitleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.textDarkColor,
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
              Bio,
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textDarkColor,
              ),
            ),
          ],
        ),
      );
    });
  }
  // ==========================================
  // SECCIÓN DE INTERESES
  // ==========================================
  
  Widget _buildInterestsSection() {
    return Obx(() {
      final interests = controller.interests;
      
      if (interests.isEmpty) {
        return SizedBox.shrink();
      }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Intereses',
                  style: ThemeColor.subtitleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.textDarkColor,
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
              'Muestra las cosas que te encantan',
              style: ThemeColor.bodySmall.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
            ),
            SizedBox(height: ThemeColor.paddingMedium),
            
            // Chips de intereses
            Wrap(
              spacing: ThemeColor.paddingSmall,
              runSpacing: ThemeColor.paddingSmall,
              children: interests.take(4).map((interest) {
                return _buildInterestChip(interest.name, _getInterestIcon(interest.name));
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInterestChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingSmall + 2,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColorfondo,
        borderRadius: ThemeColor.circularBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: ThemeColor.textDarkColor,
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.textDarkColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getInterestIcon(String interest) {
    final icons = {
      'Yoga': Icons.self_improvement,
      'Perros': Icons.pets,
      'Libros': Icons.book,
      'Festivales': Icons.festival,
      'Bailar': Icons.music_note,
      'Foodie': Icons.restaurant,
      'Conciertos': Icons.music_note,
      'Escribir': Icons.edit,
      'Café': Icons.coffee,
      'Arte': Icons.palette,
      'Museos y galerías': Icons.museum,
      'Deportes': Icons.sports_soccer,
    };
    return icons[interest] ?? Icons.favorite;
  }

  // ==========================================
  // SECCIÓN DE CUALIDADES
  // ==========================================
  
  Widget _buildQualitiesSection() {
    return Obx(() {
      final qualities = controller.qualities;
      
      if (qualities.isEmpty) {
        return SizedBox.shrink();
      }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cualidades que valoro',
                  style: ThemeColor.subtitleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.textDarkColor,
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
              'Elige hasta 3 cualidades que valoras en una persona.',
              style: ThemeColor.bodySmall.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
            ),
            SizedBox(height: ThemeColor.paddingMedium),
            
            // Chips de cualidades
            Wrap(
              spacing: ThemeColor.paddingSmall,
              runSpacing: ThemeColor.paddingSmall,
              children: qualities.take(3).map((quality) {
                return _buildQualityChip(quality.name);
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQualityChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingLarge,
        vertical: ThemeColor.paddingSmall + 2,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColorfondo,
        borderRadius: ThemeColor.circularBorderRadius,
      ),
      child: Text(
        label,
        style: ThemeColor.bodyMedium.copyWith(
          color: ThemeColor.textDarkColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}