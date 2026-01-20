import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/cast.dart';

part 'movie_model.g.dart';

@JsonSerializable()
class MovieModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'name')
  final String? name; // For TV shows

  @JsonKey(name: 'overview')
  final String? overview;

  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;

  @JsonKey(name: 'vote_average')
  final double? voteAverage;

  @JsonKey(name: 'release_date')
  final String? releaseDate;

  @JsonKey(name: 'first_air_date')
  final String? firstAirDate; // For TV shows

  @JsonKey(name: 'genre_ids')
  final List<int>? genreIds;

  @JsonKey(name: 'adult')
  final bool? adult;

  @JsonKey(name: 'popularity')
  final double? popularity;

  const MovieModel({
    required this.id,
    this.title,
    this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.releaseDate,
    this.firstAirDate,
    this.genreIds,
    this.adult,
    this.popularity,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieModelToJson(this);

  Movie toEntity() {
    return Movie(
      id: id,
      title: displayTitle,
      overview: overview ?? '',
      posterPath: posterPath ?? '',
      backdropPath: backdropPath ?? '',
      voteAverage: voteAverage ?? 0.0,
      releaseDate: displayDate,
      genreIds: genreIds ?? [],
    );
  }

  String get displayTitle => title ?? name ?? 'Untitled';
  String get displayDate => releaseDate ?? firstAirDate ?? '';
}

@JsonSerializable()
class MovieResponse {
  final int page;
  final List<MovieModel> results;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'total_results')
  final int totalResults;

  const MovieResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MovieResponseToJson(this);
}

@JsonSerializable()
class CastModel {
  final int id;
  final String name;
  final String character;
  @JsonKey(name: 'profile_path')
  final String? profilePath;

  const CastModel({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) =>
      _$CastModelFromJson(json);

  Map<String, dynamic> toJson() => _$CastModelToJson(this);

  Cast toEntity() {
    return Cast(
      id: id,
      name: name,
      character: character,
      profilePath: profilePath ?? '',
    );
  }
}

@JsonSerializable()
class CreditsResponse {
  final int id;
  final List<CastModel> cast;

  const CreditsResponse({required this.id, required this.cast});

  factory CreditsResponse.fromJson(Map<String, dynamic> json) =>
      _$CreditsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreditsResponseToJson(this);
}
