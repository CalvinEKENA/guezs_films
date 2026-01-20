import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/cast.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/tmdb_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  final TMDBRemoteDataSource remoteDataSource;

  MovieRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Movie>>> getTrendingMovies({
    String timeWindow = 'day',
  }) async {
    try {
      final response = await remoteDataSource.getTrendingMovies(
        timeWindow: timeWindow,
      );
      return Right(response.results.map((m) => m.toEntity()).toList());
    } on ApiError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1}) async {
    try {
      final response = await remoteDataSource.getPopularMovies(page: page);
      return Right(response.results.map((m) => m.toEntity()).toList());
    } on ApiError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await remoteDataSource.getTopRatedMovies(page: page);
      return Right(response.results.map((m) => m.toEntity()).toList());
    } on ApiError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getNowPlayingMovies({
    int page = 1,
  }) async {
    try {
      final response = await remoteDataSource.getNowPlayingMovies(page: page);
      return Right(response.results.map((m) => m.toEntity()).toList());
    } on ApiError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetails(int movieId) async {
    try {
      final response = await remoteDataSource.getMovieDetails(movieId);
      return Right(response.toEntity());
    } on ApiError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Cast>>> getMovieCredits(int movieId) async {
    try {
      final results = await remoteDataSource.getMovieCredits(movieId);
      return Right(results.map((c) => c.toEntity()).toList());
    } on ApiError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int movieId) async {
    try {
      final results = await remoteDataSource.getSimilarMovies(movieId);
      return Right(results.map((m) => m.toEntity()).toList());
    } on ApiError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(
    String query, {
    int page = 1,
  }) async {
    try {
      final response = await remoteDataSource.searchMovies(query, page: page);
      return Right(response.results.map((m) => m.toEntity()).toList());
    } on ApiError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure());
    }
  }
}
