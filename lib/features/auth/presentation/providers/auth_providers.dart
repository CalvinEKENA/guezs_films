import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

// Firebase instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

// Data source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(firebaseAuthProvider));
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// Use cases providers
final signInWithEmailProvider = Provider<SignInWithEmailAndPassword>((ref) {
  return SignInWithEmailAndPassword(ref.watch(authRepositoryProvider));
});

final signUpWithEmailProvider = Provider<SignUpWithEmailAndPassword>((ref) {
  return SignUpWithEmailAndPassword(ref.watch(authRepositoryProvider));
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(ref.watch(authRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

final getAuthStateChangesProvider = Provider<GetAuthStateChanges>((ref) {
  return GetAuthStateChanges(ref.watch(authRepositoryProvider));
});

// Auth state provider
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(getAuthStateChangesProvider).execute();
});

// Auth controller for UI actions
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserEntity?>>((ref) {
      return AuthController(ref);
    });

class AuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  final Ref _ref;

  AuthController(this._ref) : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(signInWithEmailProvider);
    final result = await useCase.execute(email: email, password: password);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signUp(
    String email,
    String password,
    String? displayName,
  ) async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(signUpWithEmailProvider);
    final result = await useCase.execute(
      email: email,
      password: password,
      displayName: displayName,
    );

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(signInWithGoogleUseCaseProvider);
    final result = await useCase.execute();

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(signOutProvider);
    final result = await useCase.execute();

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}
