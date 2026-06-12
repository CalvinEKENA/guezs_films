import 'package:equatable/equatable.dart';

/// Entité domaine représentant un contenu mis en favori
class FavoriteMovie extends Equatable {
  final String id;
  final String title;
  final String posterPath;
  final String contentType;
  final String addedAt;
  final bool isDeleted;
  final String updatedAt;

  const FavoriteMovie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.contentType,
    required this.addedAt,
    this.isDeleted = false,
    String? updatedAt,
  }) : updatedAt = updatedAt ?? addedAt;

  String get storageKey => '$contentType:$id';

  FavoriteMovie copyWith({
    String? id,
    String? title,
    String? posterPath,
    String? contentType,
    String? addedAt,
    bool? isDeleted,
    String? updatedAt,
  }) {
    return FavoriteMovie(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      contentType: contentType ?? this.contentType,
      addedAt: addedAt ?? this.addedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    posterPath,
    contentType,
    addedAt,
    isDeleted,
    updatedAt,
  ];
}
