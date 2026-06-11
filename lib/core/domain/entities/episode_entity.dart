import 'package:equatable/equatable.dart';

class EpisodeEntity extends Equatable {
  final String id;
  final String seriesId;
  final String seasonId;
  final int episodeNumber;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final int durationSec;
  final DateTime airDate;
  final String maturityRating;
  final List<String> subtitles;
  final String qualityVideo;
  final bool requiresAccess;
  final bool isLocked;
  final String accessMode;
  final String accessLabel;

  const EpisodeEntity({
    required this.id,
    required this.seriesId,
    required this.seasonId,
    required this.episodeNumber,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.durationSec,
    required this.airDate,
    this.maturityRating = '',
    this.subtitles = const [],
    this.qualityVideo = '',
    this.requiresAccess = false,
    this.isLocked = false,
    this.accessMode = '',
    this.accessLabel = '',
  });

  @override
  List<Object?> get props => [
    id,
    seriesId,
    seasonId,
    episodeNumber,
    title,
    description,
    thumbnailUrl,
    videoUrl,
    durationSec,
    airDate,
    maturityRating,
    subtitles,
    qualityVideo,
    requiresAccess,
    isLocked,
    accessMode,
    accessLabel,
  ];
}
