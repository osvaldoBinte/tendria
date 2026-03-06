import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/like/domain/usecase/get_pending_liked_chats_usecase.dart';
import 'package:tendria/features/like/domain/usecase/unlock_chat_usecase.dart';
import 'package:tendria/features/like/domain/entities/pending_chat_entity.dart';
import 'package:tendria/common/settings/routes_names.dart';

class LikedByUsersController extends GetxController {
  final GetPendingLikedChatsUsecase getPendingLikedChatsUsecase;
  final UnlockChatUsecase unlockChatUsecase;

  LikedByUsersController({
    required this.getPendingLikedChatsUsecase,
    required this.unlockChatUsecase,
  });

  // Estados reactivos
  final RxList<PendingChatEntity> pendingChats = <PendingChatEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingChats();
  }

  // Cargar chats pendientes
  Future<void> loadPendingChats() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await getPendingLikedChatsUsecase.execute();
      pendingChats.value = result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar chats pendientes: ${cleanExceptionMessage(e)}';
      print('Error loading pending chats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refrescar chats pendientes
  Future<void> refreshPendingChats() async {
    await loadPendingChats();
  }

  // Desbloquear chat
  Future<void> unlockChat(PendingChatEntity chat) async {
    // Mostrar diálogo de confirmación
    _showUnlockConfirmation(chat);
  }
void _showUnlockConfirmation(PendingChatEntity chat) {
  showCustomAlert(
    context: Get.context!,
    title: '¡Conecta con ${chat.name ?? 'este usuario'}!',
    message: '${chat.name ?? 'Este usuario'} quiere conectar contigo. ¿Aceptas iniciar la conversación?',
    confirmText: 'Conectar',
    cancelText: 'Ahora no',
    type: CustomAlertType.confirm,
    customWidget: chat.hiddenMessage != null
        ? Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeColor.backgroundColorfondo,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ThemeColor.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_open, size: 16, color: ThemeColor.primaryColor),
                    SizedBox(width: 4),
                    Text(
                      'Te envió un mensaje:',
                      style: ThemeColor.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ThemeColor.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  chat.hiddenMessage!,
                  style: ThemeColor.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    color: ThemeColor.textPrimaryColor,
                  ),
                ),
              ],
            ),
          )
        : null,
    onConfirm: () => _performUnlock(chat),
    onCancel: () => Get.back(),
  );
}

  // Ejecutar desbloqueo
  Future<void> _performUnlock(PendingChatEntity chat) async {
    try {
      // Mostrar loading
         showCustomAlert(
        context: Get.context!,
        title: '',
        message: 'Desbloqueando chat...',
        confirmText: '',
        type: CustomAlertType.warning,
        customWidget: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeColor.primaryColor,
            ),
          ),
        ),
      );
      // Desbloquear chat
      await unlockChatUsecase.execute(chat.chatId);

      // Cerrar loading
      Get.back();

      // Mostrar mensaje de éxito
      showSuccessSnackbar('Chat desbloqueado correctamente');

      // Remover de la lista
      await loadPendingChats();


      // Navegar al chat
      navigateToChat(chat.chatId, chat.name ?? 'Usuario');

    } catch (e) {
      // Cerrar loading si está abierto
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Mostrar error con snackbar
      showErrorSnackbar('Error al desbloquear chat: ${cleanExceptionMessage(e)}');
      
      print('Error unlocking chat: $e');
    }
  }

  // Navegar al chat
void navigateToChat(int chatId, String name) {
  Get.toNamed(RoutesNames.chatPage, arguments: {
    'chatId': chatId,
    'name': name,
    'goHomeIndex': 2, 
  });
}

  // Navegar al perfil
  void navigateToProfile(int userId) {
    
    Get.toNamed(
                            RoutesNames.userProfileDetailPage,
                            arguments: {'userId': userId},);
  }

  // Formatear tiempo transcurrido
  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Hace ${years}a';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Hace ${months}m';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes}min';
    } else {
      return 'Ahora';
    }
  }
}