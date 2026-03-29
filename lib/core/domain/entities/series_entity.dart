import 'package:equatable/equatable.dart';

class SeriesEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String backdropUrl;
  final List<String> genres;
  final int year;
  final int numberOfSeasons;
  final bool isFeatured;
  final DateTime createdAt;

  const SeriesEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.backdropUrl,
    required this.genres,
    required this.year,
    required this.numberOfSeasons,
    required this.isFeatured,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    posterUrl,
    backdropUrl,
    genres,
    year,
    numberOfSeasons,
    isFeatured,
    createdAt,
  ];
}
