import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/like/domain/entities/matches_entity.dart';
import 'package:intl/intl.dart';
import 'package:tendria/features/like/presentation/controller/my_match_controller.dart';
import 'package:tendria/features/stories/presentation/page/storyring/my_story_ring_widget.dart';
import 'package:tendria/features/stories/presentation/page/storyring/story_ring_widget.dart';
import 'package:tendria/features/stories/presentation/page/story_controller.dart';

class MyMatchView extends GetView<MyMatchController> {
  const MyMatchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Divider
            Divider(
              color: ThemeColor.dividerColor,
              height: 1,
              thickness: 1,
            ),

            // Contenido principal
            Expanded(
              child: Obx(() {
                // Loading state
                if (controller.isLoading.value && controller.matches.isEmpty) {
                  return _buildLoadingState();
                }

                // Error state
                if (controller.hasError.value && controller.matches.isEmpty) {
                  return _buildErrorState();
                }

                // Empty state
                if (controller.matches.isEmpty) {
                  return _buildEmptyState();
                }

                // Success state con historias y matches
                return RefreshIndicator(
                  onRefresh: controller.refreshMatches,
                  color: ThemeColor.primaryColor,
                  backgroundColor: ThemeColor.surfaceColor,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Sección de historias
                        _buildStoriesSection(),

                        // Separador
                        Container(
                          height: 8,
                          color: ThemeColor.backgroundColorfondo,
                        ),

                        // Header de Chats
                        _buildChatsHeader(),

                        // Lista de matches
                        _buildMatchesList(),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Header con logo y búsqueda
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              
              Text(
                'NUCLEO',
                style: ThemeColor.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Botón de búsqueda
          IconButton(
            icon: Icon(
              Icons.search,
              color: ThemeColor.textPrimaryColor,
              size: 28,
            ),
            onPressed: () {
              // Navegar a búsqueda
            },
          ),
        ],
      ),
    );
  }

  // Sección de historias
  Widget _buildStoriesSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ThemeColor.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ThemeColor.paddingMedium),
            child: Text(
              'Historias',
              style: ThemeColor.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: ThemeColor.paddingMedium),

          // Lista horizontal de historias
          SizedBox(
            height: 110,
            child: GetBuilder<StoryController>(
              init: Get.find<StoryController>(),
              builder: (storyController) {
                return Obx(() {
                  if (storyController.isLoading.value) {
                    return _buildStoriesLoading();
                  }

                  final totalUsers = storyController.allStories.length;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: ThemeColor.paddingMedium,
                    ),
                    itemCount: totalUsers + 1, // +1 para "Tu historia"
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Tu historia usando MyStoryRingWidget
                        return Column(
                          children: [
                            MyStoryRingWidget(size: 70),
                            SizedBox(height: 4),
                            SizedBox(
                              width: 70,
                              child: Text(
                                'Tu historia',
                                style: ThemeColor.caption,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }

                      // Historias de otros usuarios
                      final userIndex = index - 1;
                      return Padding(
                        padding: EdgeInsets.only(right: ThemeColor.paddingMedium),
                        child: Column(
                          children: [
                            StoryRingWidget(
                              index: userIndex,
                              size: 70,
                            ),
                            SizedBox(height: 4),
                            SizedBox(
                              width: 70,
                              child: Text(
                                storyController.getUserName(userIndex) ?? 'Usuario',
                                style: ThemeColor.caption,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Loading de historias
  Widget _buildStoriesLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: ThemeColor.paddingMedium),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: ThemeColor.paddingMedium),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ThemeColor.loaddingwithOpacity1,
                ),
              ),
              SizedBox(height: 4),
              Container(
                width: 50,
                height: 10,
                decoration: BoxDecoration(
                  color: ThemeColor.loaddingwithOpacity1,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Header de Chats
  Widget _buildChatsHeader() {
    return Padding(
      padding: EdgeInsets.all(ThemeColor.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Chats',
            style: ThemeColor.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: ThemeColor.textPrimaryColor,
            ),
            onPressed: () {
              // Mostrar filtros
            },
          ),
        ],
      ),
    );
  }

  // Lista de matches
  Widget _buildMatchesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: ThemeColor.paddingMedium),
      itemCount: controller.matches.length,
      separatorBuilder: (context, index) => Divider(
        color: ThemeColor.dividerColor,
        height: 1,
        indent: 70,
      ),
      itemBuilder: (context, index) {
        final match = controller.matches[index];
        return _buildMatchItem(match);
      },
    );
  }

  // Item de match (estilo de la imagen)
  Widget _buildMatchItem(MatchesEntity match) {
    return InkWell(
      onTap: () => controller.navigateToChat(
        match.chatId,
        match.name ?? 'Usuario',
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ThemeColor.paddingSmall + 4),
        child: Row(
          children: [
            // Avatar con gradiente
            _buildAvatar(match.photoUrl),
            SizedBox(width: ThemeColor.paddingMedium),

            // Información del match
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          match.name ?? 'Usuario',
                          style: ThemeColor.subtitleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Badge "Tu turno" (opcional - puedes agregar lógica)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColor.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tu turno',
                          style: ThemeColor.badgeText.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),

                  // Último mensaje o fecha de match
                  Text(
                    match.matchedAt != null
                        ? 'Match el ${DateFormat.yMMMd().format(match.matchedAt)}'
                        : '¡Comienza a chatear!',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Avatar con anillo de gradiente
  Widget _buildAvatar(String? photoUrl) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: ThemeColor.storyGradient,
        boxShadow: [ThemeColor.lightShadow],
      ),
      child: Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: ThemeColor.surfaceColor,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: photoUrl != null && photoUrl.isNotEmpty
              ? Image.network(
                  photoUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar();
                  },
                )
              : _buildDefaultAvatar(),
        ),
      ),
    );
  }

  // Avatar por defecto
  Widget _buildDefaultAvatar() {
    return Container(
      color: ThemeColor.backgroundColorfondo,
      child: Icon(
        Icons.person,
        size: 28,
        color: ThemeColor.textSecondaryColor,
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
            'Cargando matches...',
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
              'Error al cargar matches',
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
              onPressed: controller.loadMatches,
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
              'No tienes matches aún',
              style: ThemeColor.headingSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingSmall),
            Text(
              'Comienza a dar likes para encontrar tu match perfecto',
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