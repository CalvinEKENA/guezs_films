import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/tmdb_remote_data_source.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/cast.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/usecases/movie_usecases.dart';

// --- Data Layer Providers ---

final tmdbRemoteDataSourceProvider = Provider<TMDBRemoteDataSource>((ref) {
  return TMDBRemoteDataSourceImpl();
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final remoteDataSource = ref.watch(tmdbRemoteDataSourceProvider);
  return MovieRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Domain Layer Providers ---

final getTrendingMoviesProvider = Provider<GetTrendingMovies>((ref) {
  final repository = ref.watch(movieRepositoryProvider);
  return GetTrendingMovies(repository);
});

final getPopularMoviesProvider = Provider<GetPopularMovies>((ref) {
  final repository = ref.watch(movieRepositoryProvider);
  return GetPopularMovies(repository);
});

final getTopRatedMoviesProvider = Provider<GetTopRatedMovies>((ref) {
  final repository = ref.watch(movieRepositoryProvider);
  return GetTopRatedMovies(repository);
});

final getNowPlayingMoviesProvider = Provider<GetNowPlayingMovies>((ref) {
  final repository = ref.watch(movieRepositoryProvider);
  return GetNowPlayingMovies(repository);
});

final getMovieDetailsProvider = Provider<GetMovieDetails>((ref) {
  final repository = ref.watch(movieRepositoryProvider);
  return GetMovieDetails(repository);
});

final getMovieCreditsProvider = Provider<GetMovieCredits>((ref) {
  final repository = ref.watch(movieRepositoryProvider);
  return GetMovieCredits(repository);
});

final getSimilarMoviesUseCaseProvider = Provider<GetSimilarMovies>((ref) {
  final repository = ref.watch(movieRepositoryProvider);
  return GetSimilarMovies(repository);
});

final searchMoviesUseCaseProvider = Provider<SearchMovies>((ref) {
  final repository = ref.watch(movieRepositoryProvider);
  return SearchMovies(repository);
});

// --- Presentation Layer (State) Providers ---

final trendingMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final useCase = ref.watch(getTrendingMoviesProvider);
  final result = await useCase.execute();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movies) => movies,
  );
});

final popularMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final useCase = ref.watch(getPopularMoviesProvider);
  final result = await useCase.execute();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movies) => movies,
  );
});

final topRatedMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final useCase = ref.watch(getTopRatedMoviesProvider);
  final result = await useCase.execute();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movies) => movies,
  );
});

final nowPlayingMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final useCase = ref.watch(getNowPlayingMoviesProvider);
  final result = await useCase.execute();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movies) => movies,
  );
});

final movieDetailsProvider = FutureProvider.family<Movie, int>((
  ref,
  movieId,
) async {
  final useCase = ref.watch(getMovieDetailsProvider);
  final result = await useCase.execute(movieId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movie) => movie,
  );
});

final movieCreditsProvider = FutureProvider.family<List<Cast>, int>((
  ref,
  movieId,
) async {
  final useCase = ref.watch(getMovieCreditsProvider);
  final result = await useCase.execute(movieId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (credits) => credits,
  );
});

final similarMoviesProvider = FutureProvider.family<List<Movie>, int>((
  ref,
  movieId,
) async {
  final useCase = ref.watch(getSimilarMoviesUseCaseProvider);
  final result = await useCase.execute(movieId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movies) => movies,
  );
});

final searchResultsProvider = FutureProvider.family<List<Movie>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];
  final useCase = ref.watch(searchMoviesUseCaseProvider);
  final result = await useCase.execute(query);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movies) => movies,
  );
});
