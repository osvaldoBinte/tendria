import 'package:get/get.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/chat/presentation/page/chat_controller.dart';
import 'package:tendria/features/like/presentation/controller/my_match_controller.dart';
import 'package:tendria/features/unlock/domain/entities/unlock_entity.dart';
import 'package:tendria/features/unlock/domain/usecase/fetch_blocked_users_usecase.dart';
import 'package:tendria/features/unlock/domain/usecase/unblock_user_usecase.dart';

class BlockedUsersController extends GetxController {
  final FetchBlockedUsersUsecase fetchBlockedUsersUsecase;
  final UnblockUserUsecase unblockUserUsecase;

  BlockedUsersController({
    required this.fetchBlockedUsersUsecase,
    required this.unblockUserUsecase,
  });

  final RxList<UnlockEntity> blockedUsers = <UnlockEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUnblocking = false.obs;
  final RxSet<int> processingUserIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadBlockedUsers();
  }

  Future<void> loadBlockedUsers() async {
    try {
      isLoading.value = true;
      
      final users = await fetchBlockedUsersUsecase.execute();
      blockedUsers.value = users;
      
      if (users.isEmpty) {
        showInfoSnackbar('No tienes usuarios bloqueados');
      }
    } catch (e) {
      print('Error cargando usuarios bloqueados: $e');
      
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBlockedUsers() async {
    await loadBlockedUsers();
  }

  void showUnblockConfirmation(UnlockEntity user) {
    if (Get.context == null) return;
    
    showCustomAlert(
      context: Get.context!,
      title: 'Desbloquear usuario',
      message: '¿Estás seguro de que quieres desbloquear a ${user.username ?? "este usuario"}?',
      confirmText: 'Desbloquear',
      cancelText: 'Cancelar',
      type: CustomAlertType.warning,
      onConfirm: () => unblockUser(user.iduser),
    );
  }

  Future<void> unblockUser(int userId) async {
    if (processingUserIds.contains(userId)) return;

    try {
      processingUserIds.add(userId);
      isUnblocking.value = true;

      await unblockUserUsecase.execute(userId);

      blockedUsers.removeWhere((user) => user.iduser == userId);

      showSuccessSnackbar('Usuario desbloqueado exitosamente');
      
    final controller = Get.find<MyMatchController>();
      controller.loadChats();
    
      
   Get.offAllNamed(RoutesNames.homePage);
    } catch (e) {
      print('Error desbloqueando usuario: $e');
      showErrorSnackbar(
        'Error al desbloquear usuario: ${cleanExceptionMessage(e)}',
      );
            Get.back();

    } finally {
      processingUserIds.remove(userId);
      isUnblocking.value = processingUserIds.isNotEmpty;
    }
  }

  String getBlockedDate(DateTime? date) {
    if (date == null) return 'Fecha desconocida';
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} minutos';
      }
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace ${weeks} ${weeks == 1 ? "semana" : "semanas"}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace ${months} ${months == 1 ? "mes" : "meses"}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace ${years} ${years == 1 ? "año" : "años"}';
    }
  }
}