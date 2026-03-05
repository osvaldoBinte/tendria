
import 'package:tendria/features/notification/domain/entities/notification_entity.dart';
import 'package:tendria/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationUsecase {
  final NotificationRepository notificationRepository;
  GetNotificationUsecase({required this.notificationRepository});
  Future<List<NotificationEntity>> execute () async {
    return await notificationRepository.getNotification();
  }
}