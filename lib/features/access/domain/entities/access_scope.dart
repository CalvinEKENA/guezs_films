import 'package:equatable/equatable.dart';

enum AccessContentType { global, film, series, episode }

class AccessScope extends Equatable {
  const AccessScope({
    required this.contentType,
    this.filmId,
    this.seriesId,
    this.seasonId,
    this.episodeId,
  });

  const AccessScope.global()
    : contentType = AccessContentType.global,
      filmId = null,
      seriesId = null,
      seasonId = null,
      episodeId = null;

  const AccessScope.film(this.filmId)
    : contentType = AccessContentType.film,
      seriesId = null,
      seasonId = null,
      episodeId = null;

  const AccessScope.series(this.seriesId)
    : contentType = AccessContentType.series,
      filmId = null,
      seasonId = null,
      episodeId = null;

  const AccessScope.episode({
    required this.seriesId,
    required this.seasonId,
    required this.episodeId,
  }) : contentType = AccessContentType.episode,
       filmId = null;

  final AccessContentType contentType;
  final String? filmId;
  final String? seriesId;
  final String? seasonId;
  final String? episodeId;

  Map<String, dynamic> toMap() {
    return {
      'contentType': contentType.name,
      if (filmId != null) 'filmId': filmId,
      if (seriesId != null) 'seriesId': seriesId,
      if (seasonId != null) 'seasonId': seasonId,
      if (episodeId != null) 'episodeId': episodeId,
    };
  }

  @override
  List<Object?> get props => [
    contentType,
    filmId,
    seriesId,
    seasonId,
    episodeId,
  ];
}
