import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

/// Top-level handler for background/terminated messages.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by this point via main()
  await NotificationService.instance.showLocalNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Android notification channel for chat messages.
  static const _messageChannel = AndroidNotificationChannel(
    'messages',
    'Messages',
    description: 'New message notifications',
    importance: Importance.high,
    playSound: true,
  );

  // Callback — set by the app to handle notification taps
  void Function(int chatId)? onNotificationTap;

  Future<void> initialize() async {
    // Request permission (Android 13+, iOS)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_messageChannel);

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Notification tap when app is in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }

    // Register token with backend
    await _registerToken();

    // Listen for token refresh
    _fcm.onTokenRefresh.listen(_updateTokenOnBackend);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    // Show local notification while app is in foreground
    await showLocalNotification(message);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _handleNotificationTap(message.data);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final chatId = int.tryParse(payload);
      if (chatId != null) onNotificationTap?.call(chatId);
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final chatId = int.tryParse(data['chat_id']?.toString() ?? '');
    if (chatId != null) onNotificationTap?.call(chatId);
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final chatId = message.data['chat_id'] ?? '';

    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _messageChannel.id,
          _messageChannel.name,
          channelDescription: _messageChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
        ),
      ),
      payload: chatId,
    );
  }

  Future<void> _registerToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) await _updateTokenOnBackend(token);
    } catch (_) {}
  }

  Future<void> _updateTokenOnBackend(String token) async {
    try {
      await DioClient.instance.dio.post(
        ApiConstants.fcmToken,
        data: {'fcm_token': token},
      );
    } catch (_) {}
  }

  Future<void> clearToken() async {
    try {
      await DioClient.instance.dio.delete(ApiConstants.fcmToken);
      await _fcm.deleteToken();
    } catch (_) {}
  }
}
