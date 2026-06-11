import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/film_entity.dart';
import '../../domain/entities/season_entity.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/repositories/content_repository.dart';
import '../firebase_content_datasource.dart';

/// Implémentation Firestore du catalogue.
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
class ContentRepositoryImpl implements ContentRepository {
  const ContentRepositoryImpl({required FirebaseContentDataSource dataSource})
    : _dataSource = dataSource;

  final FirebaseContentDataSource _dataSource;

  @override
  Future<List<FilmEntity>> getFilms() => _dataSource.getFilms();

  @override
  Future<List<FilmEntity>> getFeaturedFilms() => _dataSource.getFeaturedFilms();

  @override
  Future<List<FilmEntity>> getNewFilms() => _dataSource.getNewFilms();

  @override
  Future<FilmEntity> getFilmById(String id) => _dataSource.getFilmById(id);

  @override
  Future<List<SeriesEntity>> getSeries() => _dataSource.getSeries();

  @override
  Future<List<SeriesEntity>> getFeaturedSeries() =>
      _dataSource.getFeaturedSeries();

  @override
  Future<List<SeriesEntity>> getNewSeries() => _dataSource.getNewSeries();

  @override
  Future<SeriesEntity> getSeriesById(String id) =>
      _dataSource.getSeriesById(id);

  @override
  Future<List<SeasonEntity>> getSeasons(String seriesId) =>
      _dataSource.getSeasons(seriesId);

  @override
  Future<List<EpisodeEntity>> getEpisodes(String seriesId, String seasonId) =>
      _dataSource.getEpisodes(seriesId, seasonId);

  @override
  Future<List<FilmEntity>> searchFilms(String query) =>
      _dataSource.searchFilms(query);

  @override
  Future<List<SeriesEntity>> searchSeries(String query) =>
      _dataSource.searchSeries(query);

  @override
  Future<List<FilmEntity>> getFilmsByGenre(String genre) =>
      _dataSource.getFilmsByGenre(genre);

  @override
  Future<List<SeriesEntity>> getSeriesByGenre(String genre) =>
      _dataSource.getSeriesByGenre(genre);
}
