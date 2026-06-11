import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../data/repositories/user_profile_repository_impl.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(FirebaseFirestore.instance);
});

/// Stream of all profiles for the current user
final userProfilesProvider =
    StreamProvider.family<List<UserProfileEntity>, String>((ref, userId) {
  if (userId.isEmpty) return Stream.value([]);
  return ref.watch(userProfileRepositoryProvider).watchProfiles(userId);
});

/// The currently active profile (selected at the profile selector screen)
final activeProfileProvider = StateProvider<UserProfileEntity?>((ref) => null);
