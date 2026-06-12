import 'package:equatable/equatable.dart';

enum PlayerContentType { film, episode }

class PlayerContentRequest extends Equatable {
  const PlayerContentRequest._({
    required this.contentType,
    this.filmId,
    this.seriesId,
    this.seasonId,
    this.episodeId,
  });

  factory PlayerContentRequest.film(String filmId) {
    return PlayerContentRequest._(
      contentType: PlayerContentType.film,
      filmId: filmId,
    );
  }

  factory PlayerContentRequest.episode({
    required String seriesId,
    required String seasonId,
    required String episodeId,
  }) {
    return PlayerContentRequest._(
      contentType: PlayerContentType.episode,
      seriesId: seriesId,
      seasonId: seasonId,
      episodeId: episodeId,
    );
  }

  final PlayerContentType contentType;
  final String? filmId;
  final String? seriesId;
  final String? seasonId;
  final String? episodeId;

  String get storageKey {
    return switch (contentType) {
      PlayerContentType.film => 'film:${filmId ?? ''}',
      PlayerContentType.episode =>
        'episode:${seriesId ?? ''}:${seasonId ?? ''}:${episodeId ?? ''}',
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
