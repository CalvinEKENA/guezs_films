import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/domain/entities/film_entity.dart';
import '../../../../core/domain/entities/series_entity.dart';
import '../../../../core/providers/content_providers.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  String _searchQuery = '';
  List<String> _searchHistory = const [];
  String _selectedFilter = 'Tous';

  static const List<String> _filters = ['Tous', 'Films', 'Séries', 'Acteurs'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextControllerChanged);
    unawaited(_loadSearchHistory());
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onTextControllerChanged)
      ..dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<Box<String>> _getSearchHistoryBox() async {
    if (Hive.isBoxOpen(AppConstants.searchHistoryBox)) {
      return Hive.box<String>(AppConstants.searchHistoryBox);
    }
    return Hive.openBox<String>(AppConstants.searchHistoryBox);
  }

  Future<void> _loadSearchHistory() async {
    final box = await _getSearchHistoryBox();
    final items = box.values.toList().reversed.toList(growable: false);
    if (!mounted) {
      return;
    }
    setState(() {
      _searchHistory = items;
    });
  }

  Future<void> _persistSearch(String query) async {
    final normalized = query.trim();
    if (normalized.length < 2) {
      return;
    }

    final box = await _getSearchHistoryBox();
    dynamic existingKey;

    for (final key in box.keys) {
      if (box.get(key) == normalized) {
        existingKey = key;
        break;
      }
    }

    if (existingKey != null) {
      await box.delete(existingKey);
    }

    await box.add(normalized);

    while (box.length > AppConstants.searchHistoryLimit) {
      await box.delete(box.keys.first);
    }

    await _loadSearchHistory();
  }

  Future<void> _removeHistoryItem(String query) async {
    final box = await _getSearchHistoryBox();
    dynamic targetKey;

    for (final key in box.keys) {
      if (box.get(key) == query) {
        targetKey = key;
        break;
      }
    }

    if (targetKey != null) {
      await box.delete(targetKey);
      await _loadSearchHistory();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final normalized = query.trim();

    if (normalized.isEmpty) {
      setState(() {
        _searchQuery = '';
      });
      return;
    }

    _debounceTimer = Timer(AppConstants.searchDebounce, () async {
      if (!mounted) {
        return;
      }

      setState(() {
        _searchQuery = normalized;
      });
      await _persistSearch(normalized);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _applySearch(String query) {
    final normalized = query.trim();
    _searchController.text = normalized;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: normalized.length),
    );
    setState(() {
      _searchQuery = normalized;
    });
    unawaited(_persistSearch(normalized));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            _buildFilters(),
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildEmptyState()
                  : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: AppColors.textTertiary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                onSubmitted: _applySearch,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Rechercher un film ou une série',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.textTertiary,
                onPressed: _clearSearch,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          if (_searchHistory.isNotEmpty) ...[
            Text(
              'Recherches récentes',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory
                  .map(
                    (query) => _HistoryChip(
                      label: query,
                      onTap: () => _applySearch(query),
                      onRemove: () => _removeHistoryItem(query),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 32),
          ],
          Text(
            'Genres populaires',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildGenreGrid(),
        ],
      ),
    );
  }

  Widget _buildGenreGrid() {
    final genres = [
      ('Action', Icons.local_fire_department, AppColors.genreAction),
      ('Comédie', Icons.sentiment_very_satisfied, AppColors.genreComedy),
      ('Drame', Icons.theater_comedy, AppColors.genreDrama),
      ('Horreur', Icons.nightlight_round, AppColors.genreHorror),
      ('Romance', Icons.favorite, AppColors.genreRomance),
      ('Sci-Fi', Icons.rocket_launch, AppColors.genreSciFi),
      ('Thriller', Icons.visibility, AppColors.genreThriller),
      ('Animation', Icons.animation, AppColors.genreAnimation),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final (name, icon, color) = genres[index];
        return GestureDetector(
              onTap: () => _applySearch(name),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(delay: (index * 50).ms)
            .scale(begin: const Offset(0.9, 0.9));
      },
    );
  }

  Widget _buildResults() {
    if (_selectedFilter == 'Acteurs') {
      return Center(
        child: Text(
          'Bientôt disponible',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Recherche Firestore préfixe seulement.
    // Pour une vraie recherche full-text, on pourra brancher Algolia ou Typesense plus tard.
    final filmsAsync = ref.watch(searchFilmsProvider(_searchQuery));
    final seriesAsync = ref.watch(searchSeriesProvider(_searchQuery));

    if (_selectedFilter == 'Films') {
      return _buildFilmResults(filmsAsync);
    }
    if (_selectedFilter == 'Séries') {
      return _buildSeriesResults(seriesAsync);
    }

    return _buildAllResults(filmsAsync: filmsAsync, seriesAsync: seriesAsync);
  }

  Widget _buildFilmResults(AsyncValue<List<FilmEntity>> filmsAsync) {
    return filmsAsync.when(
      data: (films) {
        if (films.isEmpty) {
          return _buildNoResultsState();
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.58,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: films.length,
          itemBuilder: (context, index) {
            final film = films[index];
            return _SearchContentCard(
              title: film.title,
              posterUrl: film.posterUrl,
              badge: 'Film',
              onTap: () => context.push('${Routes.film}/${film.id}'),
            );
          },
        );
      },
      loading: () => const ShimmerGrid(itemCount: 9),
      error: (error, stackTrace) => _buildErrorState(),
    );
  }

  Widget _buildSeriesResults(AsyncValue<List<SeriesEntity>> seriesAsync) {
    return seriesAsync.when(
      data: (seriesList) {
        if (seriesList.isEmpty) {
          return _buildNoResultsState();
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.58,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: seriesList.length,
          itemBuilder: (context, index) {
            final series = seriesList[index];
            return _SearchContentCard(
              title: series.title,
              posterUrl: series.posterUrl,
              badge: 'Série',
              onTap: () => context.push('${Routes.series}/${series.id}'),
            );
          },
        );
      },
      loading: () => const ShimmerGrid(itemCount: 9),
      error: (error, stackTrace) => _buildErrorState(),
    );
  }

  Widget _buildAllResults({
    required AsyncValue<List<FilmEntity>> filmsAsync,
    required AsyncValue<List<SeriesEntity>> seriesAsync,
  }) {
    if (filmsAsync.isLoading || seriesAsync.isLoading) {
      return const ShimmerGrid(itemCount: 9);
    }
    if (filmsAsync.hasError || seriesAsync.hasError) {
      return _buildErrorState();
    }

    final combined = [
      ...(filmsAsync.valueOrNull ?? const <FilmEntity>[]).map(
        (film) => _CombinedSearchResult(
          id: film.id,
          title: film.title,
          posterUrl: film.posterUrl,
          type: 'Film',
        ),
      ),
      ...(seriesAsync.valueOrNull ?? const <SeriesEntity>[]).map(
        (series) => _CombinedSearchResult(
          id: series.id,
          title: series.title,
          posterUrl: series.posterUrl,
          type: 'Série',
        ),
      ),
    ];

    if (combined.isEmpty) {
      return _buildNoResultsState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final item = combined[index];
        return _SearchContentCard(
          title: item.title,
          posterUrl: item.posterUrl,
          badge: item.type,
          onTap: () => context.push(
            item.type == 'Film'
                ? '${Routes.film}/${item.id}'
                : '${Routes.series}/${item.id}',
          ),
        );
      },
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Text(
        'Aucun résultat pour "$_searchQuery".',
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Text(
        'Une erreur est survenue pendant la recherche.',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchContentCard extends StatelessWidget {
  const _SearchContentCard({
    required this.title,
    required this.posterUrl,
    required this.badge,
    required this.onTap,
  });

  final String title;
  final String posterUrl;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CachedImage(
                    imageUrl: posterUrl,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 240.ms).scale(begin: const Offset(0.96, 0.96));
  }
}

class _CombinedSearchResult {
  const _CombinedSearchResult({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.type,
  });

  final String id;
  final String title;
  final String posterUrl;
  final String type;
}
