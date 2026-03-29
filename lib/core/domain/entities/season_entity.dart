import 'package:equatable/equatable.dart';

class SeasonEntity extends Equatable {
  final String id;
  final String seriesId;
  final int seasonNumber;
  final String title;

  const SeasonEntity({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.title,
  });

  @override
  List<Object?> get props => [id, seriesId, seasonNumber, title];
}
