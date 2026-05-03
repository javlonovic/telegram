abstract class ApiConstants {
  static const String baseUrl = 'http://192.168.1.102:8000/api';
  static const String wsBaseUrl = 'ws://192.168.1.102:8000';

  // Auth
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String tokenRefresh = '/auth/token/refresh/';

  // Users
  static const String users = '/users/';
  static const String me = '/users/me/';
  static const String fcmToken = '/users/fcm-token/';
  static const String contacts = '/users/contacts/';

  // Chats
  static const String chats = '/chats/';

  // Messages
  static const String messages = '/messages/';
  static const String mediaUpload = '/messages/upload/';

  // WebSocket paths
  static String chatWs(int chatId) => '$wsBaseUrl/ws/chat/$chatId/';
  static const String presenceWs = '$wsBaseUrl/ws/presence/';
}
