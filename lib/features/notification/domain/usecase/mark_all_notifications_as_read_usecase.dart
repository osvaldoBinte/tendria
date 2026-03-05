
import 'package:tendria/features/notification/domain/repositories/notification_repository.dart';

class MarkAllNotificationsAsReadUsecase {
  final NotificationRepository notificationRepository;

  MarkAllNotificationsAsReadUsecase({required this.notificationRepository});

  Future<void> execute() async {
    return await notificationRepository.markAllNotificationsAsRead( );
  }
}