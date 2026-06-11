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
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/responsive/responsive_values.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../favorites/domain/entities/favorite_movie.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';

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
  String? _selectedGenre;
  List<String> _searchHistory = const [];
  String _selectedFilter = 'Tous';

  static const List<String> _filters = ['Tous', 'Films', 'Séries'];

  static const List<String> _genres = [
    'Action',
    'Comédie',
    'Drame',
    'Romance',
    'Thriller',
    'Animation',
  ];

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
    if (!mounted) return;
    setState(() {
      _searchHistory = items;
    });
  }

  Future<void> _persistSearch(String query) async {
    final normalized = query.trim();
    if (normalized.length < 2) return;

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

    // Si on tape une recherche textuelle, on désélectionne le genre
    if (_selectedGenre != null) {
      setState(() {
        _selectedGenre = null;
      });
    }

    _debounceTimer = Timer(AppConstants.searchDebounce, () async {
      if (!mounted) return;
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
      _selectedGenre = null;
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
      _selectedGenre = null;
    });
    unawaited(_persistSearch(normalized));
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenre == genre) {
        _selectedGenre = null;
      } else {
        _selectedGenre = genre;
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          builder: (context, responsive) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(responsive),
              _buildFilters(responsive),
              _buildGenreChips(responsive),
              Expanded(
                child: (_searchQuery.isEmpty && _selectedGenre == null)
                    ? _buildEmptyState(responsive)
                    : _buildResults(responsive),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ResponsiveValues responsive) {
    return ResponsivePage(
      padding: EdgeInsets.fromLTRB(
        responsive.pagePadding,
        16,
        responsive.pagePadding,
        10,
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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
                  hintText: 'Rechercher un titre...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty || _selectedGenre != null)
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

  Widget _buildFilters(ResponsiveValues responsive) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
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
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.textOnBlue
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenreChips(ResponsiveValues responsive) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
          itemCount: _genres.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final genre = _genres[index];
            final isSelected = genre == _selectedGenre;

            return GestureDetector(
              onTap: () => _toggleGenre(genre),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.2)
                      : AppColors.surfaceVariant,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      genre,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.accent,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ResponsiveValues responsive) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive.pagePadding),
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

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.search,
                    size: 64,
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Découvrez de nouveaux films',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cherchez par titre ou explorez nos genres ci-dessus.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ResponsiveValues responsive) {
    final query = _selectedGenre ?? _searchQuery;
    final isGenreSearch = _selectedGenre != null;

    final filmsAsync = isGenreSearch
        ? ref.watch(filmsByGenreProvider(query))
        : ref.watch(searchFilmsProvider(query));

    final seriesAsync = isGenreSearch
        ? ref.watch(seriesByGenreProvider(query))
        : ref.watch(searchSeriesProvider(query));

    if (_selectedFilter == 'Films') {
      return _buildFilmResults(filmsAsync, responsive);
    }
    if (_selectedFilter == 'Séries') {
      return _buildSeriesResults(seriesAsync, responsive);
    }

    return _buildAllResults(
      filmsAsync: filmsAsync,
      seriesAsync: seriesAsync,
      responsive: responsive,
    );
  }

  Widget _buildFilmResults(
    AsyncValue<List<FilmEntity>> filmsAsync,
    ResponsiveValues responsive,
  ) {
    return filmsAsync.when(
      data: (films) {
        if (films.isEmpty) return _buildNoResultsState();
        return _buildResultsGrid(
          films
              .map(
                (f) => _CombinedSearchResult(
                  id: f.id,
                  title: f.title,
                  posterUrl: f.posterUrl,
                  type: 'Film',
                ),
              )
              .toList(),
          responsive,
        );
      },
      loading: () => ShimmerGrid(
        itemCount: responsive.posterColumns * 3,
        crossAxisCount: responsive.posterColumns,
        spacing: responsive.gridGap,
        padding: EdgeInsets.all(responsive.pagePadding),
      ),
      error: (error, stackTrace) => _buildErrorState(),
    );
  }

  Widget _buildSeriesResults(
    AsyncValue<List<SeriesEntity>> seriesAsync,
    ResponsiveValues responsive,
  ) {
    return seriesAsync.when(
      data: (seriesList) {
        if (seriesList.isEmpty) return _buildNoResultsState();
        return _buildResultsGrid(
          seriesList
              .map(
                (s) => _CombinedSearchResult(
                  id: s.id,
                  title: s.title,
                  posterUrl: s.posterUrl,
                  type: 'Série',
                ),
              )
              .toList(),
          responsive,
        );
      },
      loading: () => ShimmerGrid(
        itemCount: responsive.posterColumns * 3,
        crossAxisCount: responsive.posterColumns,
        spacing: responsive.gridGap,
        padding: EdgeInsets.all(responsive.pagePadding),
      ),
      error: (error, stackTrace) => _buildErrorState(),
    );
  }

  Widget _buildAllResults({
    required AsyncValue<List<FilmEntity>> filmsAsync,
    required AsyncValue<List<SeriesEntity>> seriesAsync,
    required ResponsiveValues responsive,
  }) {
    if (filmsAsync.isLoading || seriesAsync.isLoading) {
      return ShimmerGrid(
        itemCount: responsive.posterColumns * 3,
        crossAxisCount: responsive.posterColumns,
        spacing: responsive.gridGap,
        padding: EdgeInsets.all(responsive.pagePadding),
      );
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

    if (combined.isEmpty) return _buildNoResultsState();

    return _buildResultsGrid(combined, responsive);
  }

  Widget _buildResultsGrid(
    List<_CombinedSearchResult> items,
    ResponsiveValues responsive,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(responsive.pagePadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.posterColumns,
        childAspectRatio: 0.58,
        crossAxisSpacing: responsive.gridGap,
        mainAxisSpacing: responsive.gridGap,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _SearchContentCard(
          id: item.id,
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
        'Aucun résultat trouvé.',
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

class _SearchContentCard extends ConsumerWidget {
  const _SearchContentCard({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.badge,
    required this.onTap,
  });

  final String id;
  final String title;
  final String posterUrl;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      isFavoriteProvider((
        id: id,
        contentType: badge == 'Film' ? 'film' : 'series',
      )),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
                  // Badge
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
                          color: badge == 'Film'
                              ? AppColors.accent
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(
                              FavoriteMovie(
                                id: id,
                                title: title,
                                posterPath: posterUrl,
                                contentType: badge == 'Film'
                                    ? 'film'
                                    : 'series',
                                addedAt: DateTime.now().toIso8601String(),
                              ),
                            );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.check_rounded : Icons.add_rounded,
                          color: isFavorite ? AppColors.accent : Colors.white,
                          size: 18,
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
