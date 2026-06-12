import 'package:hive/hive.dart';

import '../../../../core/content/content_presentation.dart';
import '../../domain/entities/favorite_movie.dart';

part 'favorite_movie_model.g.dart';

/// Modèle local pour stocker un film favori dans Hive
@HiveType(typeId: 0)
class FavoriteMovieModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String posterPath;

  @HiveField(3)
  final String contentType;

  @HiveField(4)
  final String addedAt;

  @HiveField(5, defaultValue: false)
  final bool isDeleted;

  @HiveField(6)
  final String updatedAt;

  FavoriteMovieModel({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.contentType,
    required this.addedAt,
    this.isDeleted = false,
    String? updatedAt,
  }) : updatedAt = updatedAt ?? addedAt;

  String get storageKey => '$contentType:$id';

  /// Factory depuis l'entité domaine
  factory FavoriteMovieModel.fromEntity(FavoriteMovie entity) {
    return FavoriteMovieModel(
      id: entity.id,
      title: canonicalContentTitle(entity.title),
      posterPath: entity.posterPath,
      contentType: entity.contentType,
      addedAt: entity.addedAt,
      isDeleted: entity.isDeleted,
      updatedAt: entity.updatedAt,
    );
  }

  /// Conversion vers l'entité domaine
  FavoriteMovie toEntity() {
    return FavoriteMovie(
      id: id,
      title: canonicalContentTitle(title),
      posterPath: posterPath,
      contentType: contentType,
      addedAt: addedAt,
      isDeleted: isDeleted,
      updatedAt: updatedAt,
    );
  }

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'contentType': contentType,
      'addedAt': addedAt,
      'isDeleted': isDeleted,
      'updatedAt': updatedAt,
    };
  }

  /// Factory depuis Firestore Map
  factory FavoriteMovieModel.fromMap(Map<String, dynamic> map) {
    return FavoriteMovieModel(
      id: map['id'] as String,
      title: map['title'] as String,
      posterPath: map['posterPath'] as String,
      contentType: map['contentType'] as String,
      addedAt: map['addedAt'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      updatedAt: map['updatedAt'] as String?,
    );
  }
}
