import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/series_entity.dart';

class SeriesModel extends SeriesEntity {
  const SeriesModel({
    required super.id,
    required super.title,
    required super.description,
    required super.posterUrl,
    required super.backdropUrl,
    required super.genres,
    required super.year,
    required super.numberOfSeasons,
    required super.isFeatured,
    required super.createdAt,
  });

  factory SeriesModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return SeriesModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      posterUrl: data['posterUrl'] as String? ?? '',
      backdropUrl: data['backdropUrl'] as String? ?? '',
      genres: _readStringList(data['genres']),
      year: _readInt(data['year']),
      numberOfSeasons: _readInt(data['numberOfSeasons']),
      isFeatured: data['isFeatured'] as bool? ?? false,
      createdAt: _readDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'genres': genres,
      'year': year,
      'numberOfSeasons': numberOfSeasons,
      'isFeatured': isFeatured,
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

DateTime _readDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}
