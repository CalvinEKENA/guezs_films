import 'package:flutter/material.dart';

/// Represents a user profile (Netflix-style multi-profile support)
class UserProfileEntity {
  final String id;
  final String name;
  final String emoji;
  final int colorIndex;
  final bool isKids;
  final DateTime createdAt;

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorIndex,
    required this.isKids,
    required this.createdAt,
  });

  /// Predefined assets avatars (instead of emojis)
  static const List<String> emojiOptions = [
    'assets/avatars/avatar_1.png',
    'assets/avatars/avatar_2.png',
    'assets/avatars/avatar_3.png',
    'assets/avatars/avatar_4.png',
    'assets/avatars/avatar_5.png',
    'assets/avatars/avatar_6.png',
  ];

  /// Predefined color palette for profile avatars
  static const List<Color> colorOptions = [
    Color(0xFFE50914), // Rouge (primary)
    Color(0xFFFFD700), // Or (accent)
    Color(0xFF7C4DFF), // Violet
    Color(0xFF2196F3), // Bleu
    Color(0xFF46D369), // Vert
    Color(0xFFFF9800), // Orange
    Color(0xFFEC407A), // Rose
    Color(0xFF00BCD4), // Turquoise
  ];

  Color get color =>
      colorOptions[colorIndex.clamp(0, colorOptions.length - 1)];

  UserProfileEntity copyWith({
    String? id,
    String? name,
    String? emoji,
    int? colorIndex,
    bool? isKids,
    DateTime? createdAt,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorIndex: colorIndex ?? this.colorIndex,
      isKids: isKids ?? this.isKids,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
