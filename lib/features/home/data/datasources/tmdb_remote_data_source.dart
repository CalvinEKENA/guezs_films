import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/movie_model.dart';

abstract class TMDBRemoteDataSource {
  Future<MovieResponse> getTrendingMovies({String timeWindow = 'day'});
  Future<MovieResponse> getPopularMovies({int page = 1});
  Future<MovieResponse> getTopRatedMovies({int page = 1});
  Future<MovieResponse> getNowPlayingMovies({int page = 1});
  Future<MovieModel> getMovieDetails(int movieId);
  Future<List<CastModel>> getMovieCredits(int movieId);
  Future<List<MovieModel>> getSimilarMovies(int movieId);
  Future<MovieResponse> searchMovies(String query, {int page = 1});
}

class TMDBRemoteDataSourceImpl implements TMDBRemoteDataSource {
  final Dio _dio = ApiClient.instance;

  @override
  Future<MovieResponse> getTrendingMovies({String timeWindow = 'day'}) async {
    final response = await _dio.get(
      ApiConstants.getTrendingEndpoint('movie', timeWindow: timeWindow),
    );
    return MovieResponse.fromJson(response.data);
  }

  @override
  Future<MovieResponse> getPopularMovies({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.moviesPopular,
      queryParameters: {'page': page},
    );
    return MovieResponse.fromJson(response.data);
  }

  @override
  Future<MovieResponse> getTopRatedMovies({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.moviesTopRated,
      queryParameters: {'page': page},
    );
    return MovieResponse.fromJson(response.data);
  }

  @override
  Future<MovieResponse> getNowPlayingMovies({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.moviesNowPlaying,
      queryParameters: {'page': page},
    );
    return MovieResponse.fromJson(response.data);
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) async {
    final response = await _dio.get(
      ApiConstants.getMovieDetailsEndpoint(movieId),
    );
    return MovieModel.fromJson(response.data);
  }

  @override
  Future<List<CastModel>> getMovieCredits(int movieId) async {
    final response = await _dio.get(
      ApiConstants.getMovieCreditsEndpoint(movieId),
    );
    final list = (response.data['cast'] as List)
        .map((e) => CastModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  @override
  Future<List<MovieModel>> getSimilarMovies(int movieId) async {
    final response = await _dio.get(
      ApiConstants.getMovieSimilarEndpoint(movieId),
    );
    final list = (response.data['results'] as List)
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  @override
  Future<MovieResponse> searchMovies(String query, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.searchMovies,
      queryParameters: {'query': query, 'page': page},
    );
    return MovieResponse.fromJson(response.data);
  }
}
