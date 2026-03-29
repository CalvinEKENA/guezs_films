import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guezs_films/core/providers/content_providers.dart';
import 'package:guezs_films/features/auth/presentation/providers/auth_providers.dart';
import 'package:guezs_films/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:guezs_films/features/profile/domain/repositories/profile_repository.dart';

// Profile repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

// Premium status stream provider
final isPremiumProvider = StreamProvider.family<bool, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).watchPremiumStatus(userId);
});

// Profile controller for editing actions
final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
      return ProfileController(ref);
    });

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ProfileController(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateName(String name) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(profileRepositoryProvider).updateDisplayName(name);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> updateAvatar(String photoUrl) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(profileRepositoryProvider).updatePhotoUrl(photoUrl);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}
