import 'package:equatable/equatable.dart';

class FilmEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String backdropUrl;
  final String videoUrl;
  final List<String> genres;
  final int year;
  final int durationMin;
  final double rating;
  final bool isFeatured;
  final bool isNew;
  final DateTime createdAt;

  const FilmEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.backdropUrl,
    required this.videoUrl,
    required this.genres,
    required this.year,
    required this.durationMin,
    required this.rating,
    required this.isFeatured,
    required this.isNew,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    posterUrl,
    backdropUrl,
    videoUrl,
    genres,
    year,
    durationMin,
    rating,
    isFeatured,
    isNew,
    createdAt,
  ];
}
