import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/movie.dart';
import '../entities/cast.dart';
import '../repositories/movie_repository.dart';

class GetTrendingMovies {
  final MovieRepository repository;

  GetTrendingMovies(this.repository);

  Future<Either<Failure, List<Movie>>> execute({String timeWindow = 'day'}) {
    return repository.getTrendingMovies(timeWindow: timeWindow);
  }
}

class GetPopularMovies {
  final MovieRepository repository;

  GetPopularMovies(this.repository);

  Future<Either<Failure, List<Movie>>> execute({int page = 1}) {
    return repository.getPopularMovies(page: page);
  }
}

class GetTopRatedMovies {
  final MovieRepository repository;

  GetTopRatedMovies(this.repository);

  Future<Either<Failure, List<Movie>>> execute({int page = 1}) {
    return repository.getTopRatedMovies(page: page);
  }
}

class GetNowPlayingMovies {
  final MovieRepository repository;

  GetNowPlayingMovies(this.repository);

  Future<Either<Failure, List<Movie>>> execute({int page = 1}) {
    return repository.getNowPlayingMovies(page: page);
  }
}

class GetMovieDetails {
  final MovieRepository repository;

  GetMovieDetails(this.repository);

  Future<Either<Failure, Movie>> execute(int movieId) {
    return repository.getMovieDetails(movieId);
  }
}

class GetMovieCredits {
  final MovieRepository repository;

  GetMovieCredits(this.repository);

  Future<Either<Failure, List<Cast>>> execute(int movieId) {
    return repository.getMovieCredits(movieId);
  }
}

class GetSimilarMovies {
  final MovieRepository repository;

  GetSimilarMovies(this.repository);

  Future<Either<Failure, List<Movie>>> execute(int movieId) {
    return repository.getSimilarMovies(movieId);
  }
}

class SearchMovies {
  final MovieRepository repository;

  SearchMovies(this.repository);

  Future<Either<Failure, List<Movie>>> execute(String query, {int page = 1}) {
    return repository.searchMovies(query, page: page);
  }
}
