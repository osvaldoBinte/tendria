import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/like/presentation/controller/liked_by_users_controller.dart';
import 'package:tendria/features/like/domain/entities/pending_chat_entity.dart';
import 'package:tendria/features/like/domain/entities/liked_by_users_entity.dart';

class LikedByUsersView extends GetView<LikedByUsersController> {
  const LikedByUsersView({Key? key}) : super(key: key);

  LanguageController get _l => Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: ThemeColor.backgroundColorfondo,
          body: SafeArea(
            child: Column(
              children: [
                Obx(() => _buildHeader()),
                _buildTabSwitch(),
                Expanded(
                  child: Obx(() {
                    if (controller.activeTab.value == 0) {
                      return _buildPendingChatsSection();
                    } else {
                      return _buildLikesSection();
                    }
                  }),
                ),
              ],
            ),
          ),
        ));
  }

  // ==========================================
  // HEADER
  // ==========================================

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ThemeColor.paddingMedium),
      color: ThemeColor.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              ThemeColor.widgetLogo(width: 100, height: 100),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                controller.activeTab.value == 0
                    ? _l.t('pending_chats')
                    : 'Les gusté',
                style: ThemeColor.subtitleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ThemeColor.textPrimary,
                ),
              ),
              const Spacer(),
              Obx(() {
                final count = controller.activeTab.value == 0
                    ? controller.pendingChats.length
                    : controller.likedByUsers.length;
                if (count == 0) return const SizedBox.shrink();
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ThemeColor.backgroundColorfondo,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 26,
                        color: ThemeColor.textPrimary,
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                            minWidth: 20, minHeight: 20),
                        decoration: BoxDecoration(
                          color: ThemeColor.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(width: 8),
            ],
          ),
          SizedBox(height: ThemeColor.paddingSmall),
          Text(
            controller.activeTab.value == 0
                ? _l.t('unlock_hint')
                : 'Usuarios que te dieron like',
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB SWITCH
  // ==========================================

  Widget _buildTabSwitch() {
    return Obx(() => Container(
          margin: EdgeInsets.all(ThemeColor.paddingMedium),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: ThemeColor.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [ThemeColor.lightShadow],
          ),
          child: Row(
            children: [
              _buildTabItem(
                index: 0,
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Pendientes',
                count: controller.pendingChats.length,
              ),
              _buildTabItem(
                index: 1,
                icon: Icons.favorite_rounded,
                label: 'Les gusté',
                count: controller.likedByUsers.length,
              ),
            ],
          ),
        ));
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
    required int count,
  }) {
    final isActive = controller.activeTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? ThemeColor.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? ThemeColor.textLightColor
                    : ThemeColor.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? ThemeColor.textLightColor
                      : ThemeColor.textSecondary,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withOpacity(0.3)
                        : ThemeColor.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive ? ThemeColor.textLightColor : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SECCIÓN CHATS PENDIENTES
  // ==========================================

  Widget _buildPendingChatsSection() {
    if (controller.isLoading.value && controller.pendingChats.isEmpty) {
      return _buildLoadingState();
    }
    if (controller.hasError.value && controller.pendingChats.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshPendingChats,
        color: ThemeColor.primaryColor,
        backgroundColor: ThemeColor.cardBackground,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [SliverFillRemaining(child: _buildErrorState())],
        ),
      );
    }
    if (controller.pendingChats.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshPendingChats,
        color: ThemeColor.primaryColor,
        backgroundColor: ThemeColor.cardBackground,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [SliverFillRemaining(child: _buildEmptyState())],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.refreshPendingChats,
      color: ThemeColor.primaryColor,
      backgroundColor: ThemeColor.cardBackground,
      child: _buildChatGrid(),
    );
  }

  // ==========================================
  // SECCIÓN LIKES RECIBIDOS
  // ==========================================

  Widget _buildLikesSection() {
    if (controller.isLoadingLikes.value && controller.likedByUsers.isEmpty) {
      return _buildLoadingState();
    }
    if (controller.hasErrorLikes.value && controller.likedByUsers.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshLikedByUsers,
        color: ThemeColor.primaryColor,
        backgroundColor: ThemeColor.cardBackground,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [SliverFillRemaining(child: _buildLikesErrorState())],
        ),
      );
    }
    if (controller.likedByUsers.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshLikedByUsers,
        color: ThemeColor.primaryColor,
        backgroundColor: ThemeColor.cardBackground,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [SliverFillRemaining(child: _buildLikesEmptyState())],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.refreshLikedByUsers,
      color: ThemeColor.primaryColor,
      backgroundColor: ThemeColor.cardBackground,
      child: _buildLikesGrid(),
    );
  }

  Widget _buildLikesGrid() {
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
        return _buildLikeCard(user);
      },
    );
  }

  Widget _buildLikeCard(LikedByUsersEntity user) {
    return GestureDetector(
      onTap: () => controller.navigateToUserProfile(user.fromusererId),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColor.cardBackground,
          borderRadius: ThemeColor.mediumBorderRadius,
          boxShadow: [ThemeColor.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
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
                              errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        ThemeColor.primaryColor),
                                  ),
                                );
                              },
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),

                  // Badge tiempo
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        controller.getTimeAgo(user.likedAt),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Badge corazón
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.pinkAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: Colors.white, size: 16),
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

            // Info inferior
            Padding(
              padding: EdgeInsets.all(ThemeColor.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.username}, ${user.ega}',
                    style: ThemeColor.subtitleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ThemeColor.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ThemeColor.widgetButton(
                      text: 'Ver perfil',
                      onPressed: () =>
                          controller.navigateToUserProfile(user.fromusererId),
                      backgroundColor: Colors.pinkAccent,
                      textColor: Colors.white,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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

  // ==========================================
  // GRID CHATS
  // ==========================================

  Widget _buildChatGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(ThemeColor.paddingMedium),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: ThemeColor.paddingMedium,
        mainAxisSpacing: ThemeColor.paddingMedium,
      ),
      itemCount: controller.pendingChats.length,
      itemBuilder: (context, index) {
        final chat = controller.pendingChats[index];
        return _buildChatCard(chat);
      },
    );
  }

  Widget _buildChatCard(PendingChatEntity chat) {
    return GestureDetector(
      onTap: () => controller.navigateToProfile(chat.userId),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColor.cardBackground,
          borderRadius: ThemeColor.mediumBorderRadius,
          boxShadow: [ThemeColor.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ThemeColor.mediumRadius),
                      topRight: Radius.circular(ThemeColor.mediumRadius),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: ThemeColor.backgroundColorfondo,
                      child: chat.photoUrl != null && chat.photoUrl!.isNotEmpty
                          ? Image.network(
                              chat.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        ThemeColor.primaryColor),
                                  ),
                                );
                              },
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        controller.getTimeAgo(chat.createdAt),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ThemeColor.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock, color: Colors.white, size: 16),
                    ),
                  ),
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
                  if (chat.hiddenMessage != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.message,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                chat.hiddenMessage!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(ThemeColor.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.age != null
                        ? '${chat.name ?? _l.t('user')}, ${chat.age}'
                        : chat.name ?? _l.t('user'),
                    style: ThemeColor.subtitleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ThemeColor.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ThemeColor.widgetButton(
                      text: _l.t('connect'),
                      onPressed: () => controller.unlockChat(chat),
                      backgroundColor: ThemeColor.primaryColor,
                      textColor: ThemeColor.textLightColor,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildDefaultAvatar() {
    return Container(
      color: ThemeColor.backgroundColorfondo,
      child: Center(
        child: Icon(Icons.person, size: 60, color: ThemeColor.textSecondary),
      ),
    );
  }

  // ==========================================
  // ESTADOS
  // ==========================================

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.primaryColor),
          ),
          SizedBox(height: ThemeColor.paddingLarge),
          Text(
            _l.t('loading_pending'),
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

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
              child: Icon(Icons.error_outline,
                  size: 60, color: ThemeColor.errorColor),
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            Text(
              _l.t('error_title'),
              style: ThemeColor.headingSmall.copyWith(
                color: ThemeColor.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingSmall),
            Text(
              controller.errorMessage.value,
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            ThemeColor.widgetButton(
              text: _l.t('retry'),
              onPressed: controller.loadPendingChats,
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

  Widget _buildLikesErrorState() {
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
              child: Icon(Icons.error_outline,
                  size: 60, color: ThemeColor.errorColor),
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            Text(
              'Error al cargar likes',
              style: ThemeColor.headingSmall.copyWith(
                color: ThemeColor.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingSmall),
            Text(
              controller.errorMessageLikes.value,
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            ThemeColor.widgetButton(
              text: _l.t('retry'),
              onPressed: controller.refreshLikedByUsers,
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
              child: Icon(Icons.chat_bubble_outline,
                  size: 60, color: ThemeColor.primaryColor),
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            Text(
              _l.t('empty_title_pending'),
              style: ThemeColor.headingSmall.copyWith(
                color: ThemeColor.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingSmall),
            Text(
              _l.t('empty_subtitle_pending'),
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            ThemeColor.widgetButton(
              text: _l.t('explore'),
              onPressed: () => Get.offAllNamed(RoutesNames.preferencesPage),
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

  Widget _buildLikesEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ThemeColor.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border_rounded,
                  size: 60, color: Colors.pinkAccent),
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            Text(
              'Nadie te ha dado like aún',
              style: ThemeColor.headingSmall.copyWith(
                color: ThemeColor.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingSmall),
            Text(
              'Sigue explorando para conseguir más matches',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}