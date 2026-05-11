abstract class AppRoutes {
  static const String splash      = '/';
  static const String onboarding  = '/onboarding';
  static const String login       = '/login';
  static const String register    = '/register';
  static const String chats       = '/chats';
  static const String chat        = '/chat/:chatId';
  static const String profile     = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings    = '/settings';
  static const String contacts    = '/contacts';
  static const String search      = '/search';
  static const String newGroup    = '/new-group';

  static String chatPath(int id) => '/chat/$id';
}
