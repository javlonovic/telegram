abstract class ApiConstants {
  // Change to your machine's IP when testing on a physical Android device
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String wsBaseUrl = 'ws://10.0.2.2:8000';

  // Auth
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String tokenRefresh = '/auth/token/refresh/';

  // Users
  static const String users = '/users/';
  static const String me = '/users/me/';
  static const String fcmToken = '/users/fcm-token/';

  // Chats
  static const String chats = '/chats/';

  // Messages
  static const String messages = '/messages/';
  static const String mediaUpload = '/messages/upload/';
}
