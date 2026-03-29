import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/season_entity.dart';

class SeasonModel extends SeasonEntity {
  const SeasonModel({
    required super.id,
    required super.seriesId,
    required super.seasonNumber,
    required super.title,
  });

  factory SeasonModel.fromFirestore({
    required String seriesId,
    required DocumentSnapshot<Map<String, dynamic>> doc,
  }) {
    final data = doc.data() ?? <String, dynamic>{};

    return SeasonModel(
      id: doc.id,
      seriesId: seriesId,
      seasonNumber: _readInt(data['seasonNumber']),
      title: data['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'seasonNumber': seasonNumber, 'title': title};
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
