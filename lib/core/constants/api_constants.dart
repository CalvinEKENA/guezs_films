/// TMDB API Configuration
/// Get your API key at: https://developer.themoviedb.org/
class ApiConstants {
  ApiConstants._();

  // ─────────────────────────────────────────────────────────────────────────
  // Base URLs
  // ─────────────────────────────────────────────────────────────────────────

  /// TMDB API base URL
  static const String baseUrl = 'https://api.themoviedb.org/3';

  /// Image base URL for posters, backdrops, etc.
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // ─────────────────────────────────────────────────────────────────────────
  // API Keys
  // ─────────────────────────────────────────────────────────────────────────

  /// Your TMDB API key (v3 auth)
  /// Get one at: https://www.themoviedb.org/settings/api
  static const String apiKey = 'd50affd3fe676795fb0a7b8918c4e283';

  /// TMDB API Read Access Token (v4 auth) - Optional
  static const String accessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkNTBhZmZkM2ZlNjc2Nzk1ZmIwYTdiODkxOGM0ZTI4MyIsIm5iZiI6MTc2ODg5OTM3NS43MDQsInN1YiI6IjY5NmY0MzJmZDI5MTI1N2M4MDk2MjA1NyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.PrVRraOOP5JFsXPTEWJBy4gTbKxiaeBS_VwaO2vS72w';

  // ─────────────────────────────────────────────────────────────────────────
  // Image Sizes
  // ─────────────────────────────────────────────────────────────────────────

  /// Poster image sizes
  static const String posterSmall = '$imageBaseUrl/w185';
  static const String posterMedium = '$imageBaseUrl/w342';
  static const String posterLarge = '$imageBaseUrl/w500';
  static const String posterOriginal = '$imageBaseUrl/original';

  /// Backdrop image sizes
  static const String backdropSmall = '$imageBaseUrl/w300';
  static const String backdropMedium = '$imageBaseUrl/w780';
  static const String backdropLarge = '$imageBaseUrl/w1280';
  static const String backdropOriginal = '$imageBaseUrl/original';

  /// Profile (cast) image sizes
  static const String profileSmall = '$imageBaseUrl/w45';
  static const String profileMedium = '$imageBaseUrl/w185';
  static const String profileLarge = '$imageBaseUrl/h632';

  /// Logo image sizes
  static const String logoSmall = '$imageBaseUrl/w92';
  static const String logoMedium = '$imageBaseUrl/w185';
  static const String logoLarge = '$imageBaseUrl/w500';

  // ─────────────────────────────────────────────────────────────────────────
  // Movie Endpoints
  // ─────────────────────────────────────────────────────────────────────────

  static const String moviesPopular = '/movie/popular';
  static const String moviesTopRated = '/movie/top_rated';
  static const String moviesNowPlaying = '/movie/now_playing';
  static const String moviesUpcoming = '/movie/upcoming';
  static const String movieDetails = '/movie'; // /{movie_id}
  static const String movieCredits = '/movie'; // /{movie_id}/credits
  static const String movieVideos = '/movie'; // /{movie_id}/videos
  static const String movieSimilar = '/movie'; // /{movie_id}/similar
  static const String movieRecommendations =
      '/movie'; // /{movie_id}/recommendations

  // ─────────────────────────────────────────────────────────────────────────
  // TV Series Endpoints
  // ─────────────────────────────────────────────────────────────────────────

  static const String tvPopular = '/tv/popular';
  static const String tvTopRated = '/tv/top_rated';
  static const String tvOnTheAir = '/tv/on_the_air';
  static const String tvAiringToday = '/tv/airing_today';
  static const String tvDetails = '/tv'; // /{tv_id}
  static const String tvCredits = '/tv'; // /{tv_id}/credits
  static const String tvVideos = '/tv'; // /{tv_id}/videos
  static const String tvSimilar = '/tv'; // /{tv_id}/similar
  static const String tvSeasonDetails =
      '/tv'; // /{tv_id}/season/{season_number}

  // ─────────────────────────────────────────────────────────────────────────
  // Trending Endpoints
  // ─────────────────────────────────────────────────────────────────────────

  static const String trendingAll = '/trending/all'; // /day or /week
  static const String trendingMovies = '/trending/movie';
  static const String trendingTv = '/trending/tv';

  // ─────────────────────────────────────────────────────────────────────────
  // Search Endpoints
  // ─────────────────────────────────────────────────────────────────────────

  static const String searchMulti = '/search/multi';
  static const String searchMovies = '/search/movie';
  static const String searchTv = '/search/tv';
  static const String searchPerson = '/search/person';

  // ─────────────────────────────────────────────────────────────────────────
  // Discovery & Genre Endpoints
  // ─────────────────────────────────────────────────────────────────────────

  static const String discoverMovies = '/discover/movie';
  static const String discoverTv = '/discover/tv';
  static const String genresMovies = '/genre/movie/list';
  static const String genresTv = '/genre/tv/list';

  // ─────────────────────────────────────────────────────────────────────────
  // Defaults
  // ─────────────────────────────────────────────────────────────────────────

  /// Default language for API responses
  static const String defaultLanguage = 'fr-FR';

  /// Default region for API responses
  static const String defaultRegion = 'FR';

  /// Items per page for pagination
  static const int itemsPerPage = 20;

  /// Request timeout in seconds
  static const int timeoutSeconds = 30;

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Get full poster URL
  static String getPosterUrl(String? posterPath, {bool highQuality = false}) {
    if (posterPath == null || posterPath.isEmpty) return '';
    return '${highQuality ? posterLarge : posterMedium}$posterPath';
  }

  /// Get full backdrop URL
  static String getBackdropUrl(
    String? backdropPath, {
    bool highQuality = true,
  }) {
    if (backdropPath == null || backdropPath.isEmpty) return '';
    return '${highQuality ? backdropOriginal : backdropMedium}$backdropPath';
  }

  /// Get full profile URL
  static String getProfileUrl(String? profilePath, {bool highQuality = false}) {
    if (profilePath == null || profilePath.isEmpty) return '';
    return '${highQuality ? profileLarge : profileMedium}$profilePath';
  }

  /// Get movie details endpoint
  static String getMovieDetailsEndpoint(int movieId) =>
      '$movieDetails/$movieId';

  /// Get movie credits endpoint
  static String getMovieCreditsEndpoint(int movieId) =>
      '$movieDetails/$movieId/credits';

  /// Get movie videos endpoint
  /// Get movie similar movies endpoint
  static String getMovieSimilarEndpoint(int movieId) =>
      '$movieDetails/$movieId/similar';

  /// Get trending endpoint with time window
  static String getTvDetailsEndpoint(int tvId) => '$tvDetails/$tvId';

  /// Get TV season details endpoint
  static String getTvSeasonEndpoint(int tvId, int seasonNumber) =>
      '$tvDetails/$tvId/season/$seasonNumber';

  /// Get trending endpoint with time window
  static String getTrendingEndpoint(
    String mediaType, {
    String timeWindow = 'day',
  }) => '/trending/$mediaType/$timeWindow';
}
