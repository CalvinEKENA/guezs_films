import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guezs_films_site/core/errors/failures.dart';
import 'package:guezs_films_site/features/auth/presentation/providers/auth_providers.dart';
import 'package:guezs_films_site/core/providers/content_providers.dart';
import 'package:guezs_films_site/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:guezs_films_site/features/favorites/domain/entities/favorite_movie.dart';
import 'package:guezs_films_site/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:guezs_films_site/features/favorites/data/repositories/favorites_repository_impl.dart';

// Source de données Firestore
final favoritesRemoteDataSourceProvider = Provider<FavoritesRemoteDataSource>((ref) {
  return FavoritesRemoteDataSourceImpl(ref.watch(firebaseFirestoreProvider));
});

// Provider central du dépôt avec injection Hive + Firestore + Auth
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(
    remoteDataSource: ref.watch(favoritesRemoteDataSourceProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

// État des favoris dans l'app
class FavoritesNotifier extends StateNotifier<AsyncValue<List<FavoriteMovie>>> {
  final FavoritesRepository _repository;
  StreamSubscription<Either<Failure, void>>? _syncSubscription;

  FavoritesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _initialLoad();
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialLoad() async {
    // 1. Charger le local en premier pour une UI réactive
    await loadFavorites();
    
    // 2. Lancer la synchronisation temps réel silencieuse
    _startRealtimeSync();
  }

  Future<void> loadFavorites() async {
    final result = await _repository.getFavorites();
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (favorites) => state = AsyncValue.data(favorites),
    );
  }

  void _startRealtimeSync() {
    _syncSubscription?.cancel();
    _syncSubscription = _repository.watchCloudUpdates().listen((result) {
      result.fold(
        (l) => debugPrint('Silently failed realtime sync: ${l.message}'),
        (r) => loadFavorites(), // Recharger l'UI si les favoris locaux ont changé
      );
    });
  }

  Future<void> syncWithCloud() async {
    // Déclenché manuellement ou lors du re-login
    _startRealtimeSync();
  }

  Future<void> toggleFavorite(FavoriteMovie movie) async {
    final currentState = state;
    if (currentState is! AsyncData) return;

    final movies = currentState.value!;
    final isFav = movies.any((m) => m.storageKey == movie.storageKey);

    if (isFav) {
      final result = await _repository.removeFavorite(
        id: movie.id,
        contentType: movie.contentType,
      );
      result.fold((l) => null, (r) {
        final updated = movies
            .where((m) => m.storageKey != movie.storageKey)
            .toList();
        state = AsyncValue.data(updated);
      });
    } else {
      final result = await _repository.addFavorite(movie);
      result.fold((l) => null, (r) {
        final updated = [movie, ...movies];
        state = AsyncValue.data(updated);
      });
    }
  }

  bool isFavorite({required String id, required String contentType}) {
    if (state is AsyncData) {
      return state.value!.any((m) => m.storageKey == '$contentType:$id');
    }
    return false;
  }
}

// Provider de l'état "Ma Liste" entier
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<List<FavoriteMovie>>>((
      ref,
    ) {
      final repository = ref.watch(favoritesRepositoryProvider);
      final notifier = FavoritesNotifier(repository);

      // Écouter les changements d'auth pour déclencher la synchronisation cloud auto
      ref.listen(authStateProvider, (previous, next) {
        if (next.value != null && previous?.value == null) {
          // L'utilisateur vient de se connecter
          notifier.syncWithCloud();
        }
      });

      return notifier;
    });

final isFavoriteProvider =
    Provider.family<bool, ({String id, String contentType})>((ref, params) {
      final favoritesState = ref.watch(favoritesProvider);
      if (favoritesState is AsyncData) {
        return favoritesState.value!.any(
          (favorite) =>
              favorite.storageKey == '${params.contentType}:${params.id}',
        );
      }
      return false;
    });
