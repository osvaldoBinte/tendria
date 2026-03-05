
import 'package:get/get.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/features/notification/domain/entities/notification_entity.dart';
import 'package:tendria/features/notification/domain/usecase/get_notification_usecase.dart';
import 'package:tendria/features/notification/domain/usecase/mark_all_notifications_as_read_usecase.dart';

class NotificationController extends GetxController {
  final GetNotificationUsecase getNotificationUsecase;
  final MarkAllNotificationsAsReadUsecase markAllNotificationsAsReadUsecase;
  
  NotificationController({
    required this.getNotificationUsecase,
    required this.markAllNotificationsAsReadUsecase,
  });
  
  final RxList<NotificationEntity> notifications = <NotificationEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  RxBool get hasUnreadNotifications => 
    notifications.any((notification) => !notification.read).obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final result = await getNotificationUsecase.execute();
      
      result.sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          try {
            final dateA = DateTime.parse(a.createdAt!);
            final dateB = DateTime.parse(b.createdAt!);
            return dateB.compareTo(dateA);
          } catch (e) {
            print('Error parseando fechas: $e');
            return 0;
          }
        }
        
        if (a.createdAt != null) return -1;
        if (b.createdAt != null) return 1;
        
        return 0;
      });
      
      notifications.value = result;
      
      print('📬 Notificaciones cargadas: ${notifications.length}');
      print('🔔 No leídas: ${notifications.where((n) => !n.read).length}');
      
    } catch (e) {
      error.value = cleanExceptionMessage(e);
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearAllNotifications() {
    notifications.clear();
  }

  void markAsRead(int notificationId) {
    final index = notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      final notification = notifications[index];
      final updatedNotification = NotificationEntity(
        notificationId: notification.notificationId,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        imageUrl: notification.imageUrl,
        linkUrl: notification.linkUrl,
        createdAt: notification.createdAt,
        read: true,
        metadata: notification.metadata,
      );
      
      notifications[index] = updatedNotification;
      notifications.refresh();
      
      print('✅ Notificación $notificationId marcada como leída localmente');
    }
  }
  Future<void> markAllAsRead() async {
    try {
      print('🔄 Marcando todas las notificaciones como leídas en el backend...');
      
      await markAllNotificationsAsReadUsecase.execute();
      
      print('✅ Todas las notificaciones marcadas como leídas en el backend');
      
      notifications.value = notifications.map((notification) {
        return NotificationEntity(
          notificationId: notification.notificationId,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          imageUrl: notification.imageUrl,
          linkUrl: notification.linkUrl,
          createdAt: notification.createdAt,
          read: true, 
          metadata: notification.metadata,
        );
      }).toList();
      
      notifications.refresh();
      
      print('✅ Notificaciones actualizadas localmente (${notifications.length} totales)');
      print('🔔 No leídas después de marcar: ${notifications.where((n) => !n.read).length}');
      
    } catch (e) {
      print('❌ Error marcando notificaciones como leídas: $e');
      error.value = cleanExceptionMessage(e);
    }
  }
  
  void sortByDate({bool descending = true}) {
    notifications.sort((a, b) {
      if (a.createdAt != null && b.createdAt != null) {
        try {
          final dateA = DateTime.parse(a.createdAt!);
          final dateB = DateTime.parse(b.createdAt!);
          return descending 
              ? dateB.compareTo(dateA)
              : dateA.compareTo(dateB); 
        } catch (e) {
          return 0;
        }
      }
      
      if (a.createdAt != null) return descending ? -1 : 1;
      if (b.createdAt != null) return descending ? 1 : -1;
      
      return 0;
    });
    
    notifications.refresh();
  }
}