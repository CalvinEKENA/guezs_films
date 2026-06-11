import 'package:equatable/equatable.dart';

class FilmEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String backdropUrl;
  final String videoUrl;
  final List<String> genres;
  final int year;
  final int durationMin;
  final double rating;
  final bool isFeatured;
  final bool isNew;
  final DateTime createdAt;
  final String trailerUrl;
  final String director;
  final List<String> cast;
  final String country;
  final String language;
  final String maturityRating;
  final List<String> subtitles;
  final String qualityVideo;
  final bool isOriginal;
  final bool isExclusive;
  final List<String> awards;
  final int productionYear;
  final bool requiresAccess;
  final String accessMode;
  final String accessLabel;

  const FilmEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.backdropUrl,
    required this.videoUrl,
    required this.genres,
    required this.year,
    required this.durationMin,
    required this.rating,
    required this.isFeatured,
    required this.isNew,
    required this.createdAt,
    this.trailerUrl = '',
    this.director = '',
    this.cast = const [],
    this.country = '',
    this.language = '',
    this.maturityRating = '',
    this.subtitles = const [],
    this.qualityVideo = '',
    this.isOriginal = false,
    this.isExclusive = false,
    this.awards = const [],
    this.productionYear = 0,
    this.requiresAccess = false,
    this.accessMode = '',
    this.accessLabel = '',
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    posterUrl,
    backdropUrl,
    videoUrl,
    genres,
    year,
    durationMin,
    rating,
    isFeatured,
    isNew,
    createdAt,
    trailerUrl,
    director,
    cast,
    country,
    language,
    maturityRating,
    subtitles,
    qualityVideo,
    isOriginal,
    isExclusive,
    awards,
    productionYear,
    requiresAccess,
    accessMode,
    accessLabel,
  ];
}
