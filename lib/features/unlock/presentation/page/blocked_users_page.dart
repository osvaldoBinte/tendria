import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/unlock/presentation/controller/blocked_users_controller.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BlockedUsersController>();

    return Obx(() => Scaffold(
          backgroundColor: ThemeColor.backgroundColorfondo,
          appBar: AppBar(
            backgroundColor: ThemeColor.cardBackground,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ThemeColor.iconColor),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'Usuarios Bloqueados',
              style: GoogleFonts.lato(
                fontSize: 20,
                color: ThemeColor.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              Obx(() {
                if (controller.isLoading.value) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
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
                  );
                }
                return IconButton(
                  icon: Icon(Icons.refresh, color: ThemeColor.iconColor),
                  onPressed: controller.refreshBlockedUsers,
                );
              }),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading.value &&
                controller.blockedUsers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando usuarios bloqueados...',
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.blockedUsers.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: controller.refreshBlockedUsers,
              color: ThemeColor.primaryColor,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.blockedUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.blockedUsers[index];
                  return _buildBlockedUserCard(controller, user);
                },
              ),
            );
          }),
        ));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ThemeColor.cardBackground,
              shape: BoxShape.circle,
              boxShadow: [ThemeColor.lightShadow],
            ),
            child: Icon(
              Icons.block_outlined,
              size: 80,
              color: ThemeColor.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay usuarios bloqueados',
            style: ThemeColor.headingMedium.copyWith(
              color: ThemeColor.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Los usuarios que bloquees aparecerán aquí',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedUserCard(
    BlockedUsersController controller,
    dynamic user,
  ) {
    return Obx(() => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: ThemeColor.cardBackground,
            borderRadius: ThemeColor.mediumBorderRadius,
            boxShadow: [ThemeColor.lightShadow],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: ThemeColor.backgroundColorfondo,
                      backgroundImage: user.profilePictureUrl != null &&
                              user.profilePictureUrl!.isNotEmpty
                          ? NetworkImage(user.profilePictureUrl!)
                          : null,
                      child: user.profilePictureUrl == null ||
                              user.profilePictureUrl!.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 32,
                              color: ThemeColor.textSecondary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: ThemeColor.errorColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ThemeColor.cardBackground,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.block,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username ?? 'Usuario desconocido',
                        style: ThemeColor.subtitleLarge.copyWith(
                          color: ThemeColor.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (user.age != null)
                        Text(
                          '${user.age} años',
                          style: ThemeColor.bodySmall.copyWith(
                            color: ThemeColor.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: ThemeColor.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            controller.getBlockedDate(user.blockeddate),
                            style: ThemeColor.bodySmall.copyWith(
                              color: ThemeColor.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Obx(() {
                  final isThisUserProcessing =
                      controller.processingUserIds.contains(user.iduser);

                  return SizedBox(
                    width: 110,
                    child: ThemeColor.widgetButton(
                      onPressed: isThisUserProcessing
                          ? null
                          : () =>
                              controller.showUnblockConfirmation(user),
                      text: 'Desbloquear',
                      backgroundColor: ThemeColor.cardBackground,
                      borderColor: ThemeColor.primaryColor,
                      textColor: ThemeColor.primaryColor,
                      fontSize: 13,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      borderRadius: ThemeColor.smallRadius,
                      isLoading: isThisUserProcessing,
                    ),
                  );
                }),
              ],
            ),
          ),
        ));
  }
}