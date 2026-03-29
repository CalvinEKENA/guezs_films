import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/episode_entity.dart';

class EpisodeModel extends EpisodeEntity {
  const EpisodeModel({
    required super.id,
    required super.seriesId,
    required super.seasonId,
    required super.episodeNumber,
    required super.title,
    required super.description,
    required super.thumbnailUrl,
    required super.videoUrl,
    required super.durationSec,
    required super.airDate,
  });

  factory EpisodeModel.fromFirestore({
    required String seriesId,
    required String seasonId,
    required DocumentSnapshot<Map<String, dynamic>> doc,
  }) {
    final data = doc.data() ?? <String, dynamic>{};

    return EpisodeModel(
      id: doc.id,
      seriesId: seriesId,
      seasonId: seasonId,
      episodeNumber: _readInt(data['episodeNumber']),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
      durationSec: _readInt(data['durationSec']),
      airDate: _readDateTime(data['airDate']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'episodeNumber': episodeNumber,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'durationSec': durationSec,
      'airDate': Timestamp.fromDate(airDate),
    };
  }
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

DateTime _readDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}
