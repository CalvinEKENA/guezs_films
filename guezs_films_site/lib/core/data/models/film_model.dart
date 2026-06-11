import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/film_entity.dart';

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
  });

  factory FilmModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    return FilmModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      posterUrl: data['posterUrl'] as String? ?? '',
      backdropUrl: data['backdropUrl'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
      genres: _readStringList(data['genres']),
      year: _readInt(data['year']),
      durationMin: _readInt(data['durationMin']),
      rating: _readDouble(data['rating']),
      isFeatured: data['isFeatured'] as bool? ?? false,
      isNew: data['isNew'] as bool? ?? false,
      createdAt: _readDateTime(data['createdAt']),
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
    };
  }
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

DateTime _readDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}
