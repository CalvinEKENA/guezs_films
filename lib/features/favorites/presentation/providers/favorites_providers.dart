import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/favorite_movie.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../data/repositories/favorites_repository_impl.dart';

// Provider central du dépôt
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl();
});

// État des favoris dans l'app
class FavoritesNotifier extends StateNotifier<AsyncValue<List<FavoriteMovie>>> {
  final FavoritesRepository _repository;

  FavoritesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = const AsyncValue.loading();
    final result = await _repository.getFavorites();
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (favorites) => state = AsyncValue.data(favorites),
    );
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
      return FavoritesNotifier(ref.watch(favoritesRepositoryProvider));
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
