import 'package:cloud_firestore/cloud_firestore.dart';

import '../../content/content_presentation.dart';
import '../../domain/entities/film_entity.dart';
import 'video_url_field_reader.dart';

class FilmModel extends FilmEntity {
  const FilmModel({
    required super.id,
    required super.title,
    required super.description,
    required super.posterUrl,
    required super.backdropUrl,
    required super.videoUrl,
    required super.genres,
    required super.year,
    required super.durationMin,
    required super.rating,
    required super.isFeatured,
    required super.isNew,
    required super.createdAt,
    super.trailerUrl,
    super.director,
    super.cast,
    super.country,
    super.language,
    super.maturityRating,
    super.subtitles,
    super.qualityVideo,
    super.isOriginal,
    super.isExclusive,
    super.awards,
    super.productionYear,
    super.requiresAccess,
    super.accessMode,
    super.accessLabel,
  });

  factory FilmModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    return FilmModel(
      id: doc.id,
      title: canonicalContentTitle(data['title'] as String? ?? ''),
      description: canonicalContentCopy(data['description'] as String? ?? ''),
      posterUrl: data['posterUrl'] as String? ?? '',
      backdropUrl: data['backdropUrl'] as String? ?? '',
      videoUrl: readVideoUrl(data),
      genres: _readStringList(data['genres']),
      year: _readInt(data['year']),
      durationMin: _readInt(data['durationMin']),
      rating: _readDouble(data['rating']),
      isFeatured: data['isFeatured'] as bool? ?? false,
      isNew: data['isNew'] as bool? ?? false,
      createdAt: _readDateTime(data['createdAt']),
      trailerUrl: _readString(data['trailerUrl']),
      director: _readString(data['director']),
      cast: _readStringList(data['cast']),
      country: _readString(data['country']),
      language: _readString(data['language']),
      maturityRating: _readString(data['maturityRating']),
      subtitles: _readStringList(data['subtitles']),
      qualityVideo: _readString(data['qualityVideo'], data['videoQuality']),
      isOriginal: _readBool(data['isOriginal']),
      isExclusive: _readBool(data['isExclusive']),
      awards: _readStringList(data['awards']),
      productionYear: _readInt(data['productionYear']),
      requiresAccess: _readRequiresAccess(data),
      accessMode: _readString(data['accessMode']),
      accessLabel: _readString(data['accessLabel']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'videoUrl': videoUrl,
      'genres': genres,
      'year': year,
      'durationMin': durationMin,
      'rating': rating,
      'isFeatured': isFeatured,
      'isNew': isNew,
      'createdAt': Timestamp.fromDate(createdAt),
      if (trailerUrl.isNotEmpty) 'trailerUrl': trailerUrl,
      if (director.isNotEmpty) 'director': director,
      if (cast.isNotEmpty) 'cast': cast,
      if (country.isNotEmpty) 'country': country,
      if (language.isNotEmpty) 'language': language,
      if (maturityRating.isNotEmpty) 'maturityRating': maturityRating,
      if (subtitles.isNotEmpty) 'subtitles': subtitles,
      if (qualityVideo.isNotEmpty) 'qualityVideo': qualityVideo,
      if (isOriginal) 'isOriginal': isOriginal,
      if (isExclusive) 'isExclusive': isExclusive,
      if (awards.isNotEmpty) 'awards': awards,
      if (productionYear > 0) 'productionYear': productionYear,
      if (requiresAccess) 'requiresAccess': requiresAccess,
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

double _readDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
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
