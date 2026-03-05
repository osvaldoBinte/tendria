
import 'package:tendria/features/notification/domain/repositories/notification_repository.dart';

class SaveTokenFcmUsecase {
  final NotificationRepository notificationRepository;
  SaveTokenFcmUsecase({required this.notificationRepository});
  Future<void>execute (String fcm,String dispositivo,) async {
    return await notificationRepository.savetokenFCM(fcm,dispositivo);
  }
}