import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/like/presentation/controller/liked_by_users_controller.dart';
import 'package:tendria/features/like/domain/entities/liked_by_users_entity.dart';

class LikedByUsersView extends GetView<LikedByUsersController> {
  const LikedByUsersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColorfondo,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Contenido
            Expanded(
              child: Obx(() {
                // Loading state
                if (controller.isLoading.value && controller.likedByUsers.isEmpty) {
                  return _buildLoadingState();
                }

                // Error state
                if (controller.hasError.value && controller.likedByUsers.isEmpty) {
                  return _buildErrorState();
                }

                // Empty state
                if (controller.likedByUsers.isEmpty) {
                  return _buildEmptyState();
                }

                // Lista de usuarios
                return RefreshIndicator(
                  onRefresh: controller.refreshLikedByUsers,
                  color: ThemeColor.primaryColor,
                  backgroundColor: ThemeColor.surfaceColor,
                  child: _buildUserGrid(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ThemeColor.paddingMedium),
      color: ThemeColor.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo y título
          Row(
            children: [
             
              SizedBox(width: 8),
              Text(
                'tendria',
                style: ThemeColor.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Interesados en ti',
                style: ThemeColor.subtitleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: ThemeColor.paddingSmall),

          // Descripción
          Text(
            'Devuelve el interés y deja que la conexión fluya.',
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Grid de usuarios
  Widget _buildUserGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(ThemeColor.paddingMedium),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: ThemeColor.paddingMedium,
        mainAxisSpacing: ThemeColor.paddingMedium,
      ),
      itemCount: controller.likedByUsers.length,
      itemBuilder: (context, index) {
        final user = controller.likedByUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  // Card de usuario
  Widget _buildUserCard(LikedByUsersEntity user) {
    return GestureDetector(
      onTap: () => controller.navigateToProfile(user.fromusererId),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          borderRadius: ThemeColor.mediumBorderRadius,
          boxShadow: [ThemeColor.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: Stack(
                children: [
                  // Foto de perfil
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ThemeColor.mediumRadius),
                      topRight: Radius.circular(ThemeColor.mediumRadius),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: ThemeColor.backgroundColorfondo,
                      child: user.profilePictureUrl.isNotEmpty
                          ? Image.network(
                              user.profilePictureUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar();
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ThemeColor.primaryColor,
                                    ),
                                  ),
                                );
                              },
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),

                  // Badge de tiempo
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        controller.getTimeAgo(user.likedAt),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Gradiente inferior
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Información
            Padding(
              padding: EdgeInsets.all(ThemeColor.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y edad
                  Text(
                    '${user.username}, ${user.ega}',
                    style: ThemeColor.subtitleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  // Botón de dar like
                  SizedBox(
                    width: double.infinity,
                    child: ThemeColor.widgetButton(
                      text: 'Me interesa',
                      onPressed: () => controller.likeBack(user),
                      backgroundColor: ThemeColor.primaryColor,
                      textColor: ThemeColor.textLightColor,
                      fontSize: 12,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      borderRadius: ThemeColor.smallRadius,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Avatar por defecto
  Widget _buildDefaultAvatar() {
    return Container(
      color: ThemeColor.backgroundColorfondo,
      child: Center(
        child: Icon(
          Icons.person,
          size: 60,
          color: ThemeColor.textSecondaryColor,
        ),
      ),
    );
  }

  // Estado de carga
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeColor.primaryColor,
            ),
          ),
          SizedBox(height: ThemeColor.paddingLarge),
          Text(
            'Cargando interesados...',
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Estado de error
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ThemeColor.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              decoration: BoxDecoration(
                color: ThemeColor.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: ThemeColor.errorColor,
              ),
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            Text(
              'Error al cargar usuarios',
              style: ThemeColor.headingSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingSmall),
            Text(
              controller.errorMessage.value,
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            ThemeColor.widgetButton(
              text: 'REINTENTAR',
              onPressed: controller.loadLikedByUsers,
              backgroundColor: ThemeColor.primaryColor,
              textColor: ThemeColor.textLightColor,
              padding: EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingLarge,
                vertical: ThemeColor.paddingMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ThemeColor.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 60,
                color: ThemeColor.primaryColor,
              ),
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            Text(
              'Aún no tienes interesados',
              style: ThemeColor.headingSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingSmall),
            Text(
              'Cuando alguien se interese en ti, aparecerá aquí',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            ThemeColor.widgetButton(
              text: 'EXPLORAR PERFILES',
              onPressed: () => Get.back(),
              backgroundColor: ThemeColor.primaryColor,
              textColor: ThemeColor.textLightColor,
              padding: EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingLarge,
                vertical: ThemeColor.paddingMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}