
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/features/notification/data/datasources/notification_data_sources_imp.dart';
import 'package:tendria/features/notification/domain/entities/notification_entity.dart';
import 'package:tendria/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImp extends NotificationRepository {
  final NotificationDataSourcesImp notificationDataSourcesImp;
  AuthService authService = AuthService();
  NotificationRepositoryImp({required this.notificationDataSourcesImp});
  @override
  Future<List<NotificationEntity>> getNotification() async {
    final token = await authService.getToken() ?? (throw Exception('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await notificationDataSourcesImp.getnotification(token);
  }
    
  @override
  Future<void> savetokenFCM(String fcm,String dispositivo,) async {
    final token = await authService.getToken() ?? (throw Exception( 'No hay sesión activa. El usuario debe iniciar sesión.'));

    return await notificationDataSourcesImp.savetokenFCM(fcm,dispositivo, token);
  }
  
  @override
  Future<void> markAllNotificationsAsRead() async {
        final token = await authService.getToken() ?? (throw Exception( 'No hay sesión activa. El usuario debe iniciar sesión.'));
    return await notificationDataSourcesImp.markAllNotificationsAsRead(token);
  }
 
}
