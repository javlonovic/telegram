abstract class AppRoutes {
  static const String splash      = '/';
  static const String onboarding  = '/onboarding';
  static const String login       = '/login';
  static const String register    = '/register';

  // Root authenticated screen
  static const String chats       = '/chats';

  // Children of /chats — use context.go() with these full paths
  static const String chat        = '/chats/:chatId';
  static const String profile     = '/chats/profile';
  static const String editProfile = '/chats/profile/edit';
  static const String settings    = '/chats/settings';
  static const String contacts    = '/chats/contacts';
  static const String search      = '/chats/search';
  static const String newGroup    = '/chats/new-group';

  /// Build a chat path for a specific id
  static String chatPath(int id) => '/chats/$id';
}
