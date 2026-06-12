import 'package:cloud_firestore/cloud_firestore.dart';

import '../../content/content_presentation.dart';
import '../../domain/entities/episode_entity.dart';
import 'video_url_field_reader.dart';

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
    super.maturityRating,
    super.subtitles,
    super.qualityVideo,
    super.requiresAccess,
    super.isLocked,
    super.accessMode,
    super.accessLabel,
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
      title: canonicalContentTitle(data['title'] as String? ?? ''),
      description: canonicalContentCopy(data['description'] as String? ?? ''),
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      videoUrl: readVideoUrl(data),
      durationSec: _readInt(data['durationSec']),
      airDate: _readDateTime(data['airDate']),
      maturityRating: _readString(data['maturityRating']),
      subtitles: _readStringList(data['subtitles']),
      qualityVideo: _readString(data['qualityVideo'], data['videoQuality']),
      requiresAccess: _readRequiresAccess(data),
      isLocked: _readBool(data['isLocked']),
      accessMode: _readString(data['accessMode']),
      accessLabel: _readString(data['accessLabel']),
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
      if (maturityRating.isNotEmpty) 'maturityRating': maturityRating,
      if (subtitles.isNotEmpty) 'subtitles': subtitles,
      if (qualityVideo.isNotEmpty) 'qualityVideo': qualityVideo,
      if (requiresAccess) 'requiresAccess': requiresAccess,
      if (isLocked) 'isLocked': isLocked,
      if (accessMode.isNotEmpty) 'accessMode': accessMode,
      if (accessLabel.isNotEmpty) 'accessLabel': accessLabel,
    };
  }
}

String _readString(dynamic value, [dynamic fallback]) {
  if (value is String) return value.trim();
  if (fallback is String) return fallback.trim();
  return '';
}

List<String> _readStringList(dynamic value) {
  if (value is List) {
    return value.whereType<String>().toList(growable: false);
  }
  return const [];
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

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

bool _readRequiresAccess(Map<String, dynamic> data) {
  if (data['requiresAccess'] != null) {
    return _readBool(data['requiresAccess']);
  }

  final accessMode = _readString(data['accessMode']).toLowerCase();
  return accessMode == 'coderequired' ||
      accessMode == 'code_required' ||
      accessMode == 'premium' ||
      accessMode == 'purchaserequired' ||
      accessMode == 'purchase_required';
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
