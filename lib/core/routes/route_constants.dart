/// Content type enum for details page
enum ContentType { movie, series }

/// Route paths
class Routes {
  Routes._();

  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  // Main tabs
  static const String home = '/home';
  static const String search = '/search';
  static const String downloads = '/downloads';
  static const String profile = '/profile';

  // Content
  static const String movie = '/movie';
  static const String series = '/series';
  static const String player = '/player';
}
