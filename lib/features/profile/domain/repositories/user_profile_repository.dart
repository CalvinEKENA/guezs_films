import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Stream<List<UserProfileEntity>> watchProfiles(String userId);

  Future<UserProfileEntity> createProfile({
    required String userId,
    required String name,
    required String emoji,
    required int colorIndex,
    required bool isKids,
  });

  Future<void> updateProfile({
    required String userId,
    required String profileId,
    required String name,
    required String emoji,
    required int colorIndex,
    required bool isKids,
  });

  Future<void> deleteProfile({
    required String userId,
    required String profileId,
  });
}
