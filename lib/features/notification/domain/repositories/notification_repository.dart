
import 'package:tendria/features/notification/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotification();
  Future<void> savetokenFCM(String fcm,String dispositivo,);
  Future<void> markAllNotificationsAsRead( );

}