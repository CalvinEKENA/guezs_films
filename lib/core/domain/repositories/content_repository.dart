import '../entities/episode_entity.dart';
import '../entities/film_entity.dart';
import '../entities/season_entity.dart';
import '../entities/series_entity.dart';

/// Référentiel du catalogue Firestore.
///
/// Structure cible documentée:
/// `/films/{filmId}` avec les champs `title`, `description`, `posterUrl`,
/// `backdropUrl`, `videoUrl`, `genres`, `year`, `durationMin`, `rating`,
/// `isFeatured`, `isNew`, `createdAt`.
/// `/series/{seriesId}` avec les champs `title`, `description`, `posterUrl`,
/// `backdropUrl`, `genres`, `year`, `numberOfSeasons`, `isFeatured`,
/// `createdAt`.
/// `/series/{seriesId}/seasons/{seasonId}` avec `seasonNumber`, `title`.
/// `/series/{seriesId}/seasons/{seasonId}/episodes/{episodeId}` avec
/// `episodeNumber`, `title`, `description`, `thumbnailUrl`, `videoUrl`,
/// `durationSec`, `airDate`.
abstract class ContentRepository {
  Future<List<FilmEntity>> getFilms();
  Future<List<FilmEntity>> getFeaturedFilms();
  Future<List<FilmEntity>> getNewFilms();
  Future<FilmEntity> getFilmById(String id);
  Future<List<SeriesEntity>> getSeries();
  Future<List<SeriesEntity>> getFeaturedSeries();
  Future<SeriesEntity> getSeriesById(String id);
  Future<List<SeasonEntity>> getSeasons(String seriesId);
  Future<List<EpisodeEntity>> getEpisodes(String seriesId, String seasonId);
  Future<List<FilmEntity>> searchFilms(String query);
  Future<List<SeriesEntity>> searchSeries(String query);
  Future<List<FilmEntity>> getFilmsByGenre(String genre);
  Future<List<SeriesEntity>> getSeriesByGenre(String genre);
}
