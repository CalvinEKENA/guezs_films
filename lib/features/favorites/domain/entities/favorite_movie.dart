import 'package:equatable/equatable.dart';

/// Entité domaine représentant un contenu mis en favori
class FavoriteMovie extends Equatable {
  final String id;
  final String title;
  final String posterPath;
  final String contentType;
  final String addedAt;

  const FavoriteMovie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.contentType,
    required this.addedAt,
  });

  String get storageKey => '$contentType:$id';

  @override
  List<Object?> get props => [id, title, posterPath, contentType, addedAt];
}
