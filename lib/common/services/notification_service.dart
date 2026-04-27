import 'dart:convert';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'dart:io' show Platform;

import 'package:tendria/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("📬 Handling a background message: ${message.messageId}");

  try {
    final prefs = await SharedPreferences.getInstance();

    int currentCount = prefs.getInt('unread_notifications') ?? 0;
    currentCount++;

    final saved = await prefs.setInt('unread_notifications', currentCount);
    final savedFlag = await prefs.setBool('has_new_notifications', true);

    await prefs.reload();

    final verifyCount = prefs.getInt('unread_notifications');
    final verifyFlag = prefs.getBool('has_new_notifications');

    print("✅ Background: Contador guardado = $currentCount");
    print("✅ Background: Saved success = $saved && $savedFlag");
    print("✅ Background: Verificación - count=$verifyCount, flag=$verifyFlag");
  } catch (e) {
    print("❌ Error guardando contador en background: $e");
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  String? fcmToken;

  final RxInt unreadNotificationsCount = 0.obs;
  final RxBool hasNewNotifications = false.obs;

  Function? onNotificationReceived;
  Function? onFetchNotifications;

  SharedPreferences? _prefs;
  static const String _keyUnreadCount = 'unread_notifications';
  static const String _keyHasNew = 'has_new_notifications';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    await _loadPersistedCount();
    await _initLocalNotifications();

    if (Platform.isIOS) {
      await _setupiOSNotifications();
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _generateFCMToken();
    _listenToTokenRefresh();
    _setupMessageListeners();
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

await _localNotifications.initialize(settings:
  initSettings,
  onDidReceiveNotificationResponse: (NotificationResponse response) {
    print('🔔 Notificación tocada: ${response.payload}');
    // ✅ Aquí sí navegamos, porque el usuario tocó el banner
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationNavigation(data);
      } catch (e) {
        print('❌ Error parseando payload: $e');
      }
    }
  },
);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notificaciones',
      description: 'Canal de notificaciones principales',
      importance: Importance.high,
      playSound: true,
    );

     await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
  }

  Future<void> _setupiOSNotifications() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _loadPersistedCount() async {
    try {
      await _prefs?.reload();

      final count = _prefs?.getInt(_keyUnreadCount) ?? 0;
      final hasNew = _prefs?.getBool(_keyHasNew) ?? false;

      unreadNotificationsCount.value = count;
      hasNewNotifications.value = hasNew;

      print('📱 Contador cargado desde almacenamiento: $count');
      print('🔔 Tiene notificaciones nuevas: $hasNew');
    } catch (e) {
      print('❌ Error cargando contador: $e');
    }
  }

  Future<void> _saveCount() async {
    try {
      final savedCount = await _prefs?.setInt(
        _keyUnreadCount,
        unreadNotificationsCount.value,
      );
      final savedFlag = await _prefs?.setBool(
        _keyHasNew,
        hasNewNotifications.value,
      );

      await _prefs?.reload();

      print(
        '💾 Contador guardado: ${unreadNotificationsCount.value} (success: $savedCount && $savedFlag)',
      );
    } catch (e) {
      print('❌ Error guardando contador: $e');
    }
  }

  Future<void> _generateFCMToken() async {
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        print('✅ FCM Token generado: $fcmToken');
      } else {
        print('❌ No se pudo generar el token FCM');
      }
    } catch (e) {
      print('❌ Error al generar token FCM: $e');
    }
  }

  void _listenToTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh
        .listen((newToken) {
          fcmToken = newToken;
          print('🔄 Token FCM actualizado: $newToken');
        })
        .onError((error) {
          print('❌ Error al actualizar token: $error');
        });
  }

  Future<String?> getToken() async {
    if (fcmToken != null) {
      return fcmToken;
    }

    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      return fcmToken;
    } catch (e) {
      print('❌ Error al obtener token: $e');
      return null;
    }
  }

  Future<void> sendTokenToServer(String token) async {
    try {
      print('📤 Token enviado al servidor: $token');
    } catch (e) {
      print('❌ Error al enviar token al servidor: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      fcmToken = null;
      print('🗑️ Token FCM eliminado');
    } catch (e) {
      print('❌ Error al eliminar token: $e');
    }
  }

  void _setupMessageListeners() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    _checkInitialMessage();
  }

void _handleForegroundMessage(RemoteMessage message) {
  print('📨 Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    incrementUnreadCount();
    onNotificationReceived?.call();
    onFetchNotifications?.call();
    _showLocalNotification(message); 
  }
}

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Canal para notificaciones importantes de Gerena',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@drawable/logo',
      color: Color(0xFFFFFFFF),
    );

    const NotificationDetails details = NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
    );

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );

    print('📲 Notificación local mostrada: ${notification.title}');
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('📱 Message opened app from background: ${message.data}');
    incrementUnreadCount();
    onNotificationReceived?.call();
    onFetchNotifications?.call();

    _handleNotificationNavigation(message.data);
  }

  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print('🚀 App opened from terminated state: ${initialMessage.data}');
      await incrementUnreadCount();
      onFetchNotifications?.call();

      await Future.delayed(const Duration(milliseconds: 1500));
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final tipo = data['Tipo'] as String?;
    final chatIdRaw = data['ChatId'] as String?;
    final senderIdRaw = data['SenderId'] as String?;
    final pendiente =
        data['pendienteAceptacion']?.toString().toLowerCase() == 'true';

    if (tipo != 'Mensaje') return;

    if (pendiente) {
      final senderId = int.tryParse(senderIdRaw ?? '');
      if (senderId == null) return;

      print('👤 Navegando al perfil: $senderId');
      Get.toNamed(
        RoutesNames.userProfileDetailPage,
        arguments: {'userId': senderId},
      );
    } else {
      final chatId = int.tryParse(chatIdRaw ?? '');
      if (chatId == null) return;

      print('💬 Navegando al chat: $chatId');
      Get.toNamed(
        RoutesNames.chatPage,
        arguments: {
          'chatId': chatId,
          'goHomeIndex': 3,
        },
      );
    }
  }

  Future<void> incrementUnreadCount() async {
    unreadNotificationsCount.value++;
    hasNewNotifications.value = true;
    await _saveCount();
    print('📬 Notificaciones no leídas: ${unreadNotificationsCount.value}');
  }

  Future<void> clearUnreadCount() async {
    unreadNotificationsCount.value = 0;
    hasNewNotifications.value = false;
    await _saveCount();
    print('✅ Notificaciones marcadas como leídas');
  }

  Future<void> markAsRead(int count) async {
    unreadNotificationsCount.value =
        (unreadNotificationsCount.value - count).clamp(0, 999);
    if (unreadNotificationsCount.value == 0) {
      hasNewNotifications.value = false;
    }
    await _saveCount();
    print(
      '✅ $count notificaciones marcadas como leídas. Restantes: ${unreadNotificationsCount.value}',
    );
  }

  Future<void> reloadFromStorage() async {
    await _loadPersistedCount();
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print('📢 Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    print('🔇 Unsubscribed from topic: $topic');
  }
}