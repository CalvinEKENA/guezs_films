/// Route paths
class Routes {
  Routes._();

  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // Main tabs
  static const String home = '/home';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String downloads = '/downloads';
  static const String profile = '/profile';
  static const String support = '/support';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfUse = '/terms-of-use';

  // Content
  static const String film = '/film';
  static const String series = '/series';
  static const String watch = '/watch';
  static const String watchFilm = '/watch/film/:filmId';
  static const String watchEpisode =
      '/watch/series/:seriesId/season/:seasonId/episode/:episodeId';

  /// Deprecated legacy player route. Keep only for local downloads and
  /// temporary backward compatibility while watch routes become the default.
  static const String player = '/player';

  // Profile selector (shown after login)
  static const String profileSelector = '/profile-selector';

  static String filmDetailsPath(String filmId) {
    return '$film/${Uri.encodeComponent(filmId)}';
  }

  static String seriesDetailsPath(String seriesId) {
    return '$series/${Uri.encodeComponent(seriesId)}';
  }

  static String filmWatchPath(String filmId) {
    return '$watch/film/${Uri.encodeComponent(filmId)}';
  }

  static String episodeWatchPath({
    required String seriesId,
    required String seasonId,
    required String episodeId,
  }) {
    return '$watch/series/${Uri.encodeComponent(seriesId)}'
        '/season/${Uri.encodeComponent(seasonId)}'
        '/episode/${Uri.encodeComponent(episodeId)}';
  }

  static String legacyPlayerPath({
    required String videoUrl,
    required String title,
    String? posterUrl,
  }) {
    return Uri(
      path: player,
      queryParameters: {
        'url': videoUrl,
        'title': title,
        if (posterUrl != null && posterUrl.isNotEmpty) 'posterUrl': posterUrl,
      },
    ).toString();
  }
}
