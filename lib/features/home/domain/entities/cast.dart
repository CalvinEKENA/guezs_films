import 'package:equatable/equatable.dart';

class Cast extends Equatable {
  final int id;
  final String name;
  final String character;
  final String profilePath;

  const Cast({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  @override
  List<Object?> get props => [id, name, character, profilePath];
}
