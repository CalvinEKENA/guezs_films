import 'package:hive/hive.dart';
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

  FavoriteMovieModel({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.contentType,
    required this.addedAt,
  });

  String get storageKey => '$contentType:$id';

  /// Factory depuis l'entité domaine
  factory FavoriteMovieModel.fromEntity(FavoriteMovie entity) {
    return FavoriteMovieModel(
      id: entity.id,
      title: entity.title,
      posterPath: entity.posterPath,
      contentType: entity.contentType,
      addedAt: entity.addedAt,
    );
  }

  /// Conversion vers l'entité domaine
  FavoriteMovie toEntity() {
    return FavoriteMovie(
      id: id,
      title: title,
      posterPath: posterPath,
      contentType: contentType,
      addedAt: addedAt,
    );
  }
}
