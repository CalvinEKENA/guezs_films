/// Application Constants
/// General app-wide constants and configuration
class AppConstants {
  AppConstants._();

  // ─────────────────────────────────────────────────────────────────────────
  // App Info
  // ─────────────────────────────────────────────────────────────────────────

  static const String appName = 'Guezs Films';
  static const String appTagline = 'Your Premium Streaming Experience';
  static const String appVersion = '1.0.0';

  // ─────────────────────────────────────────────────────────────────────────
  // Timing Constants
  // ─────────────────────────────────────────────────────────────────────────

  /// Splash screen display duration
  static const Duration splashDuration = Duration(seconds: 3);

  /// Hero carousel auto-rotation interval
  static const Duration carouselInterval = Duration(seconds: 8);

  /// Search debounce duration
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// Snackbar display duration
  static const Duration snackbarDuration = Duration(seconds: 3);

  /// Video player controls auto-hide delay
  static const Duration playerControlsHideDelay = Duration(seconds: 3);

  /// Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ─────────────────────────────────────────────────────────────────────────
  // Layout Constants
  // ─────────────────────────────────────────────────────────────────────────

  /// Standard screen padding
  static const double screenPadding = 16.0;

  /// Content section title padding
  static const double sectionPadding = 12.0;

  /// Card spacing in grids
  static const double cardSpacing = 12.0;

  /// Movie poster aspect ratio (2:3)
  static const double posterAspectRatio = 2 / 3;

  /// Backdrop aspect ratio (16:9)
  static const double backdropAspectRatio = 16 / 9;

  /// Hero section height ratio (relative to screen height)
  static const double heroHeightRatio = 0.65;

  /// Horizontal content list item width
  static const double contentItemWidth = 120.0;

  /// Top 10 item width (larger for ranking number)
  static const double top10ItemWidth = 140.0;

  // ─────────────────────────────────────────────────────────────────────────
  // Responsive Breakpoints
  // ─────────────────────────────────────────────────────────────────────────

  /// Mobile breakpoint
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint
  static const double tabletBreakpoint = 900;

  /// Desktop breakpoint
  static const double desktopBreakpoint = 1200;

  /// Grid columns for mobile
  static const int mobileGridColumns = 2;

  /// Grid columns for tablet
  static const int tabletGridColumns = 4;

  /// Grid columns for desktop
  static const int desktopGridColumns = 6;

  // ─────────────────────────────────────────────────────────────────────────
  // Pagination & Limits
  // ─────────────────────────────────────────────────────────────────────────

  /// Number of items to fetch per page
  static const int itemsPerPage = 20;

  /// Maximum profiles per account
  static const int maxProfiles = 4;

  /// Maximum download queue size
  static const int maxDownloads = 25;

  /// Search history limit
  static const int searchHistoryLimit = 10;

  /// Continue watching limit
  static const int continueWatchingLimit = 15;

  // ─────────────────────────────────────────────────────────────────────────
  // Video Player
  // ─────────────────────────────────────────────────────────────────────────

  /// Skip intro/outro duration (seconds)
  static const int skipDuration = 10;

  /// Double tap seek duration (seconds)
  static const int doubleTapSeek = 10;

  /// Resume threshold - don't resume if less than this many seconds from end
  static const int resumeThresholdSeconds = 120;

  /// Mark as watched if this percentage completed
  static const double watchedThreshold = 0.9;

  // ─────────────────────────────────────────────────────────────────────────
  // Storage Keys
  // ─────────────────────────────────────────────────────────────────────────

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String currentProfileKey = 'current_profile';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String qualityKey = 'playback_quality';
  static const String subtitlesEnabledKey = 'subtitles_enabled';
  static const String autoPlayKey = 'auto_play_next';

  // ─────────────────────────────────────────────────────────────────────────
  // Hive Box Names
  // ─────────────────────────────────────────────────────────────────────────

  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
  static const String watchHistoryBox = 'watch_history_box';
  static const String favoritesBox = 'favorites_box';
  static const String downloadBox = 'download_box';
  static const String searchHistoryBox = 'search_history';

  // ─────────────────────────────────────────────────────────────────────────
  // Content Categories
  // ─────────────────────────────────────────────────────────────────────────

  static const List<String> movieGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Science Fiction',
    'Thriller',
    'War',
    'Western',
  ];

  static const List<String> tvGenres = [
    'Action & Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Kids',
    'Mystery',
    'News',
    'Reality',
    'Sci-Fi & Fantasy',
    'Soap',
    'Talk',
    'War & Politics',
    'Western',
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Quality Options
  // ─────────────────────────────────────────────────────────────────────────

  static const List<String> videoQualities = [
    'Auto',
    '4K Ultra HD',
    '1080p Full HD',
    '720p HD',
    '480p SD',
    '360p',
  ];
}
