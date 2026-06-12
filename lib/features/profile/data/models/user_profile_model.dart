import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.emoji,
    required super.colorIndex,
    required super.isKids,
    required super.createdAt,
  });

  factory UserProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserProfileModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Profil',
      emoji: data['emoji'] as String? ?? '🎬',
      colorIndex: (data['colorIndex'] as num?)?.toInt() ?? 0,
      isKids: data['isKids'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'emoji': emoji,
    'colorIndex': colorIndex,
    'isKids': isKids,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  @override
  UserProfileModel copyWith({
    String? id,
    String? name,
    String? emoji,
    int? colorIndex,
    bool? isKids,
    DateTime? createdAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorIndex: colorIndex ?? this.colorIndex,
      isKids: isKids ?? this.isKids,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
