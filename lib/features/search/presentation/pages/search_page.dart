import 'dart:async';

import 'package:flutter/material.dart';
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
import '../../../../core/search/search_normalization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/search_result_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  String _searchQuery = '';
  String? _selectedGenre;
  String? _selectedCountry;
  String? _selectedLanguage;
  List<String> _searchHistory = const [];
  _SearchFilter _selectedFilter = _SearchFilter.all;
  bool _isDebouncing = false;

  bool get _hasActiveFilters =>
      _selectedFilter != _SearchFilter.all ||
      _selectedGenre != null ||
      _selectedCountry != null ||
      _selectedLanguage != null;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshSearchField);
    _searchFocusNode.addListener(_refreshSearchField);
    unawaited(_loadSearchHistory());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController
      ..removeListener(_refreshSearchField)
      ..dispose();
    _searchFocusNode
      ..removeListener(_refreshSearchField)
      ..dispose();
    super.dispose();
  }

  void _refreshSearchField() {
    if (mounted) setState(() {});
  }

  Box<String>? _getSearchHistoryBox() {
    try {
      if (Hive.isBoxOpen(AppConstants.searchHistoryBox)) {
        return Hive.box<String>(AppConstants.searchHistoryBox);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadSearchHistory() async {
    try {
      final box = _getSearchHistoryBox();
      if (box == null) return;
      final items = box.values.toList().reversed.toList(growable: false);
      if (!mounted) return;
      setState(() => _searchHistory = items);
    } catch (_) {
      if (mounted) setState(() => _searchHistory = const []);
    }
  }

  Future<void> _persistSearch(String query) async {
    final normalized = query.trim();
    if (normalizeSearchText(normalized).length < minimumSearchLength) return;

    try {
      final box = _getSearchHistoryBox();
      if (box == null) return;
      dynamic existingKey;
      for (final key in box.keys) {
        if (normalizeSearchText(box.get(key) ?? '') ==
            normalizeSearchText(normalized)) {
          existingKey = key;
          break;
        }
      }

      if (existingKey != null) await box.delete(existingKey);
      await box.add(normalized);
      while (box.length > AppConstants.searchHistoryLimit) {
        await box.delete(box.keys.first);
      }
      await _loadSearchHistory();
    } catch (_) {
      // Search remains available when local history storage is unavailable.
    }
  }

  Future<void> _removeHistoryItem(String query) async {
    try {
      final box = _getSearchHistoryBox();
      if (box == null) return;
      dynamic targetKey;
      for (final key in box.keys) {
        if (box.get(key) == query) {
          targetKey = key;
          break;
        }
      }
      if (targetKey != null) await box.delete(targetKey);
      await _loadSearchHistory();
    } catch (_) {
      // History is an optional convenience.
    }
  }

  Future<void> _clearHistory() async {
    try {
      final box = _getSearchHistoryBox();
      if (box == null) return;
      await box.clear();
    } catch (_) {
      // Keep the UI responsive if local storage is unavailable.
    }
    if (mounted) setState(() => _searchHistory = const []);
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    final query = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    final normalized = normalizeSearchText(query);

    if (normalized.length < minimumSearchLength) {
      setState(() {
        _searchQuery = '';
        _isDebouncing = false;
      });
      return;
    }

    setState(() => _isDebouncing = true);
    _debounceTimer = Timer(AppConstants.searchDebounce, () {
      if (!mounted) return;
      setState(() {
        _searchQuery = query.toLowerCase();
        _isDebouncing = false;
      });
      unawaited(_persistSearch(query));
    });
  }

  void _submitSearch(String value) {
    _debounceTimer?.cancel();
    final query = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizeSearchText(query).length < minimumSearchLength) {
      setState(() {
        _searchQuery = '';
        _isDebouncing = false;
      });
      return;
    }

    setState(() {
      _searchQuery = query.toLowerCase();
      _isDebouncing = false;
    });
    _searchFocusNode.unfocus();
    unawaited(_persistSearch(query));
  }

  void _applyHistorySearch(String query) {
    _searchController
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    _submitSearch(query);
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isDebouncing = false;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedFilter = _SearchFilter.all;
      _selectedGenre = null;
      _selectedCountry = null;
      _selectedLanguage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filmsAsync = ref.watch(filmsProvider);
    final seriesAsync = ref.watch(seriesProvider);
    final catalogItems = _catalogItems(
      filmsAsync.valueOrNull ?? const [],
      seriesAsync.valueOrNull ?? const [],
    );
    final filterOptions = _SearchFilterOptions.fromItems(catalogItems);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          builder: (context, responsive) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(responsive),
                _buildPrimaryFilters(responsive, filterOptions),
                if (filterOptions.genres.isNotEmpty)
                  _buildGenreFilters(responsive, filterOptions.genres),
                if (filterOptions.countries.isNotEmpty ||
                    filterOptions.languages.isNotEmpty)
                  _buildMetadataFilters(responsive, filterOptions),
                Expanded(
                  child: _buildBody(
                    responsive: responsive,
                    catalogFilms: filmsAsync,
                    catalogSeries: seriesAsync,
                    catalogItems: catalogItems,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveValues responsive) {
    return ResponsivePage(
      padding: EdgeInsets.fromLTRB(
        responsive.pagePadding,
        responsive.isDesktop ? 26 : 16,
        responsive.pagePadding,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explorer',
            style:
                (responsive.isDesktop
                        ? AppTextStyles.displaySmall
                        : AppTextStyles.headlineLarge)
                    .copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Films, séries et sélections à découvrir.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: responsive.isDesktop ? 58 : 54,
              decoration: BoxDecoration(
                color: AppColors.surfaceObsidian.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _searchFocusNode.hasFocus
                      ? AppColors.glassBorder(0.72)
                      : AppColors.border.withValues(alpha: 0.72),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.brandGold,
                    size: 23,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _onSearchChanged,
                      onSubmitted: _submitSearch,
                      textInputAction: TextInputAction.search,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enableSuggestions: true,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Rechercher un film, une série, un réalisateur…',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_isDebouncing)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.spotlightBlue,
                        ),
                      ),
                    )
                  else if (_searchController.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Effacer la recherche',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
          if (_searchController.text.trim().isNotEmpty &&
              normalizeSearchText(_searchController.text).length <
                  minimumSearchLength) ...[
            const SizedBox(height: 8),
            Text(
              'Saisissez au moins 2 caractères.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrimaryFilters(
    ResponsiveValues responsive,
    _SearchFilterOptions options,
  ) {
    final filters = _SearchFilter.values
        .where(
          (filter) =>
              filter != _SearchFilter.exclusive ||
              options.hasExclusive ||
              _selectedFilter == _SearchFilter.exclusive,
        )
        .toList(growable: false);

    return SizedBox(
      height: 43,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return _PremiumChoiceChip(
            label: filter.label,
            selected: filter == _selectedFilter,
            onTap: () => setState(() => _selectedFilter = filter),
          );
        },
      ),
    );
  }

  Widget _buildGenreFilters(ResponsiveValues responsive, List<String> genres) {
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
          itemCount: genres.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final genre = genres[index];
            return _PremiumChoiceChip(
              label: genre,
              compact: true,
              selected: genre == _selectedGenre,
              onTap: () {
                setState(() {
                  _selectedGenre = _selectedGenre == genre ? null : genre;
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetadataFilters(
    ResponsiveValues responsive,
    _SearchFilterOptions options,
  ) {
    return ResponsivePage(
      padding: EdgeInsets.fromLTRB(
        responsive.pagePadding,
        10,
        responsive.pagePadding,
        2,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (options.countries.isNotEmpty)
            _FilterMenuButton(
              icon: Icons.public_rounded,
              label: _selectedCountry ?? 'Pays',
              options: options.countries,
              selectedValue: _selectedCountry,
              onSelected: (value) {
                setState(() => _selectedCountry = value);
              },
            ),
          if (options.languages.isNotEmpty)
            _FilterMenuButton(
              icon: Icons.translate_rounded,
              label: _selectedLanguage ?? 'Langue',
              options: options.languages,
              selectedValue: _selectedLanguage,
              onSelected: (value) {
                setState(() => _selectedLanguage = value);
              },
            ),
          if (_hasActiveFilters)
            TextButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 17),
              label: const Text('Réinitialiser'),
            ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required ResponsiveValues responsive,
    required AsyncValue<List<FilmEntity>> catalogFilms,
    required AsyncValue<List<SeriesEntity>> catalogSeries,
    required List<_SearchItem> catalogItems,
  }) {
    if (_searchQuery.isNotEmpty) {
      return _buildTextSearchResults(responsive);
    }

    if (_hasActiveFilters) {
      if (catalogFilms.isLoading || catalogSeries.isLoading) {
        return _buildLoadingState(responsive);
      }
      if (catalogFilms.hasError || catalogSeries.hasError) {
        return _buildState(
          responsive: responsive,
          icon: Icons.cloud_off_rounded,
          title: 'Le catalogue ne répond pas',
          message:
              'Vérifiez votre connexion puis relancez le chargement des contenus.',
          actionLabel: 'Réessayer',
          onAction: _retryCatalog,
        );
      }

      final filtered = _filterAndSortItems(catalogItems);
      if (catalogItems.isEmpty) {
        return _buildCatalogEmptyState(responsive);
      }
      return _buildResults(
        items: filtered,
        responsive: responsive,
        title: 'Sélection',
      );
    }

    return _buildDiscovery(
      responsive: responsive,
      filmsAsync: catalogFilms,
      seriesAsync: catalogSeries,
      items: catalogItems,
    );
  }

  Widget _buildTextSearchResults(ResponsiveValues responsive) {
    final includeFilms = _selectedFilter != _SearchFilter.series;
    final includeSeries = _selectedFilter != _SearchFilter.films;
    final filmsAsync = includeFilms
        ? ref.watch(searchFilmsProvider(_searchQuery))
        : null;
    final seriesAsync = includeSeries
        ? ref.watch(searchSeriesProvider(_searchQuery))
        : null;

    if (filmsAsync?.isLoading == true || seriesAsync?.isLoading == true) {
      return _buildLoadingState(responsive);
    }
    if (filmsAsync?.hasError == true || seriesAsync?.hasError == true) {
      return _buildState(
        responsive: responsive,
        icon: Icons.wifi_off_rounded,
        title: 'Recherche interrompue',
        message:
            'Impossible de consulter le catalogue pour le moment. Réessayez dans quelques instants.',
        actionLabel: 'Réessayer',
        onAction: _retrySearch,
      );
    }

    final items = [
      ...?filmsAsync?.valueOrNull?.map(_SearchItem.fromFilm),
      ...?seriesAsync?.valueOrNull?.map(_SearchItem.fromSeries),
    ];
    final filtered = _filterAndSortItems(items, query: _searchQuery);
    return _buildResults(
      items: filtered,
      responsive: responsive,
      title: 'Résultats pour “${_searchController.text.trim()}”',
    );
  }

  Widget _buildDiscovery({
    required ResponsiveValues responsive,
    required AsyncValue<List<FilmEntity>> filmsAsync,
    required AsyncValue<List<SeriesEntity>> seriesAsync,
    required List<_SearchItem> items,
  }) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: responsive.pagePadding + 24),
      child: ResponsivePage(
        padding: EdgeInsets.fromLTRB(
          responsive.pagePadding,
          22,
          responsive.pagePadding,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeading(
              title: 'Recherches récentes',
              actionLabel: _searchHistory.isEmpty ? null : 'Tout effacer',
              onAction: _searchHistory.isEmpty ? null : _clearHistory,
            ),
            const SizedBox(height: 12),
            if (_searchHistory.isEmpty)
              _InlineEmptyHistory(onSearchTap: _requestSearchFocus)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _searchHistory
                    .map(
                      (query) => _HistoryChip(
                        label: query,
                        onTap: () => _applyHistorySearch(query),
                        onRemove: () => _removeHistoryItem(query),
                      ),
                    )
                    .toList(growable: false),
              ),
            const SizedBox(height: 32),
            const _SectionHeading(
              title: 'Tendances du moment',
              subtitle: 'Les sélections qui attirent les regards.',
            ),
            const SizedBox(height: 16),
            if (filmsAsync.isLoading || seriesAsync.isLoading)
              _DiscoveryLoading(responsive: responsive)
            else if (filmsAsync.hasError || seriesAsync.hasError)
              _InlineCatalogError(onRetry: _retryCatalog)
            else if (items.isEmpty)
              _InlineCatalogEmpty(onRetry: _retryCatalog)
            else
              _SearchGrid(
                items: _trendingItems(items),
                responsive: responsive,
                scrollable: false,
                onOpen: _openItem,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults({
    required List<_SearchItem> items,
    required ResponsiveValues responsive,
    required String title,
  }) {
    if (items.isEmpty) {
      return _buildState(
        responsive: responsive,
        icon: Icons.manage_search_rounded,
        title: 'Aucun contenu trouvé',
        message:
            'Essayez un autre titre, un genre différent ou retirez un filtre.',
        actionLabel: _hasActiveFilters ? 'Réinitialiser les filtres' : null,
        onAction: _hasActiveFilters ? _resetFilters : null,
      );
    }

    return ResponsivePage(
      padding: EdgeInsets.fromLTRB(
        responsive.pagePadding,
        20,
        responsive.pagePadding,
        responsive.pagePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${items.length} résultat${items.length > 1 ? 's' : ''}',
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.brandGoldLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _SearchGrid(
              items: items,
              responsive: responsive,
              onOpen: _openItem,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ResponsiveValues responsive) {
    return ResponsivePage(
      padding: EdgeInsets.all(responsive.pagePadding),
      child: ShimmerGrid(
        itemCount: responsive.posterColumns * 2,
        crossAxisCount: responsive.posterColumns,
        spacing: responsive.gridGap,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCatalogEmptyState(ResponsiveValues responsive) {
    return _buildState(
      responsive: responsive,
      icon: Icons.movie_filter_outlined,
      title: 'Le catalogue est encore vide',
      message:
          'Les prochains films et séries apparaîtront ici dès leur publication.',
      actionLabel: 'Actualiser',
      onAction: _retryCatalog,
    );
  }

  Widget _buildState({
    required ResponsiveValues responsive,
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.pagePadding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: AppColors.surfaceObsidian.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder(0.28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withValues(alpha: 0.34),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: AppColors.brandGoldLight),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandGold,
                      foregroundColor: AppColors.textOnGold,
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(actionLabel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_SearchItem> _filterAndSortItems(
    List<_SearchItem> items, {
    String? query,
  }) {
    final filtered = items.where((item) {
      if (query != null && !matchesSearchQuery(query, item.searchableValues)) {
        return false;
      }
      if (_selectedFilter == _SearchFilter.films && !item.isFilm) return false;
      if (_selectedFilter == _SearchFilter.series && item.isFilm) return false;
      if (_selectedFilter == _SearchFilter.newReleases && !item.isNew) {
        return false;
      }
      if (_selectedFilter == _SearchFilter.popular && !item.isPopular) {
        return false;
      }
      if (_selectedFilter == _SearchFilter.exclusive && !item.isExclusive) {
        return false;
      }
      if (_selectedGenre != null &&
          !item.genres.any(
            (genre) =>
                normalizeSearchText(genre) ==
                normalizeSearchText(_selectedGenre!),
          )) {
        return false;
      }
      if (_selectedCountry != null &&
          normalizeSearchText(item.country) !=
              normalizeSearchText(_selectedCountry!)) {
        return false;
      }
      if (_selectedLanguage != null &&
          normalizeSearchText(item.language) !=
              normalizeSearchText(_selectedLanguage!)) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (query != null) {
        final normalizedQuery = normalizeSearchText(query);
        final aTitle = normalizeSearchText(a.title);
        final bTitle = normalizeSearchText(b.title);
        final aStarts = aTitle.startsWith(normalizedQuery);
        final bStarts = bTitle.startsWith(normalizedQuery);
        if (aStarts != bStarts) return aStarts ? -1 : 1;
      }
      if (_selectedFilter == _SearchFilter.newReleases) {
        return b.createdAt.compareTo(a.createdAt);
      }
      final scoreComparison = b.discoveryScore.compareTo(a.discoveryScore);
      if (scoreComparison != 0) return scoreComparison;
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  List<_SearchItem> _trendingItems(List<_SearchItem> items) {
    final sorted = [...items]
      ..sort((a, b) => b.discoveryScore.compareTo(a.discoveryScore));
    return sorted.take(12).toList(growable: false);
  }

  void _requestSearchFocus() {
    _searchFocusNode.requestFocus();
  }

  void _retryCatalog() {
    ref
      ..invalidate(filmsProvider)
      ..invalidate(seriesProvider);
  }

  void _retrySearch() {
    ref
      ..invalidate(searchFilmsProvider(_searchQuery))
      ..invalidate(searchSeriesProvider(_searchQuery));
  }

  void _openItem(_SearchItem item) {
    _searchFocusNode.unfocus();
    context.push(
      item.isFilm
          ? Routes.filmDetailsPath(item.id)
          : Routes.seriesDetailsPath(item.id),
    );
  }
}

enum _SearchFilter {
  all('Tous'),
  films('Films'),
  series('Séries'),
  newReleases('Nouveautés'),
  popular('Populaires'),
  exclusive('Exclusifs');

  const _SearchFilter(this.label);
  final String label;
}

class _SearchFilterOptions {
  const _SearchFilterOptions({
    required this.genres,
    required this.countries,
    required this.languages,
    required this.hasExclusive,
  });

  factory _SearchFilterOptions.fromItems(List<_SearchItem> items) {
    final genres = <String>{};
    final countries = <String>{};
    final languages = <String>{};
    var hasExclusive = false;

    for (final item in items) {
      genres.addAll(item.genres.where((genre) => genre.trim().isNotEmpty));
      if (item.country.trim().isNotEmpty) countries.add(item.country.trim());
      if (item.language.trim().isNotEmpty) languages.add(item.language.trim());
      hasExclusive = hasExclusive || item.isExclusive;
    }

    return _SearchFilterOptions(
      genres: genres.toList()..sort(),
      countries: countries.toList()..sort(),
      languages: languages.toList()..sort(),
      hasExclusive: hasExclusive,
    );
  }

  final List<String> genres;
  final List<String> countries;
  final List<String> languages;
  final bool hasExclusive;
}

class _SearchItem {
  const _SearchItem({
    required this.id,
    required this.isFilm,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.year,
    required this.rating,
    required this.genres,
    required this.director,
    required this.cast,
    required this.country,
    required this.language,
    required this.isFeatured,
    required this.isNew,
    required this.isOriginal,
    required this.isExclusive,
    required this.createdAt,
  });

  factory _SearchItem.fromFilm(FilmEntity film) {
    return _SearchItem(
      id: film.id,
      isFilm: true,
      title: film.title,
      description: film.description,
      posterUrl: film.posterUrl,
      year: film.productionYear > 0 ? film.productionYear : film.year,
      rating: film.rating,
      genres: film.genres,
      director: film.director,
      cast: film.cast,
      country: film.country,
      language: film.language,
      isFeatured: film.isFeatured,
      isNew: film.isNew || _recentlyAdded(film.createdAt),
      isOriginal: film.isOriginal,
      isExclusive: film.isExclusive,
      createdAt: film.createdAt,
    );
  }

  factory _SearchItem.fromSeries(SeriesEntity series) {
    return _SearchItem(
      id: series.id,
      isFilm: false,
      title: series.title,
      description: series.description,
      posterUrl: series.posterUrl,
      year: series.productionYear > 0 ? series.productionYear : series.year,
      rating: null,
      genres: series.genres,
      director: series.director,
      cast: series.cast,
      country: series.country,
      language: series.language,
      isFeatured: series.isFeatured,
      isNew: _recentlyAdded(series.createdAt),
      isOriginal: series.isOriginal,
      isExclusive: series.isExclusive,
      createdAt: series.createdAt,
    );
  }

  final String id;
  final bool isFilm;
  final String title;
  final String description;
  final String posterUrl;
  final int year;
  final double? rating;
  final List<String> genres;
  final String director;
  final List<String> cast;
  final String country;
  final String language;
  final bool isFeatured;
  final bool isNew;
  final bool isOriginal;
  final bool isExclusive;
  final DateTime createdAt;

  Iterable<String> get searchableValues => [
    title,
    description,
    director,
    ...cast,
    country,
    language,
    ...genres,
  ];

  bool get isPopular => isFeatured || (rating ?? 0) >= 7;

  double get discoveryScore {
    final age = DateTime.now().difference(createdAt).inDays;
    return (isFeatured ? 20 : 0) +
        (isExclusive ? 12 : 0) +
        (isOriginal ? 8 : 0) +
        (isNew ? 7 : 0) +
        (rating ?? 0) +
        (age <= 45 ? 5 : 0);
  }

  String get contentType => isFilm ? 'Film' : 'Série';

  String? get premiumBadge {
    if (isExclusive) return 'Exclusivité';
    if (isOriginal) return 'GUEZS Original';
    if (isNew) return 'Nouveau';
    if (isFeatured) return 'Sélection';
    return null;
  }
}

class _SearchGrid extends StatelessWidget {
  const _SearchGrid({
    required this.items,
    required this.responsive,
    required this.onOpen,
    this.scrollable = true,
  });

  final List<_SearchItem> items;
  final ResponsiveValues responsive;
  final ValueChanged<_SearchItem> onOpen;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = responsive.posterColumns;
        final cardWidth =
            (constraints.maxWidth - (responsive.gridGap * (columns - 1))) /
            columns;
        final cardHeight = cardWidth * 1.5 + 66;

        return GridView.builder(
          shrinkWrap: !scrollable,
          physics: scrollable
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: cardHeight,
            crossAxisSpacing: responsive.gridGap,
            mainAxisSpacing: responsive.gridGap + 6,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return SearchResultCard(
              title: item.title,
              posterUrl: item.posterUrl,
              contentType: item.contentType,
              year: item.year,
              rating: item.rating,
              premiumBadge: item.premiumBadge,
              onTap: () => onOpen(item),
            );
          },
        );
      },
    );
  }
}

class _PremiumChoiceChip extends StatelessWidget {
  const _PremiumChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 13 : 16,
            vertical: compact ? 7 : 9,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.brandBlue
                : AppColors.surfaceObsidian.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.glassBorder(0.72)
                  : AppColors.border.withValues(alpha: 0.68),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected
                  ? AppColors.brandGoldLight
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterMenuButton extends StatelessWidget {
  const _FilterMenuButton({
    required this.icon,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: label,
      color: AppColors.bottomSheet,
      onSelected: (value) => onSelected(value.isEmpty ? null : value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: '', child: Text('Tous')),
        ...options.map(
          (option) => PopupMenuItem(
            value: option,
            child: Row(
              children: [
                Expanded(child: Text(option)),
                if (option == selectedValue)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.brandGold,
                  ),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selectedValue == null
              ? AppColors.surfaceObsidian.withValues(alpha: 0.74)
              : AppColors.brandBlue.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selectedValue == null
                ? AppColors.border
                : AppColors.glassBorder(0.58),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: AppColors.brandGoldLight),
            const SizedBox(width: 7),
            Text(label, style: AppTextStyles.labelMedium),
            const SizedBox(width: 5),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.sectionTitle),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: AppTextStyles.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
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
    return Material(
      color: AppColors.surfaceObsidian.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 7, 6, 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.history_rounded,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 7),
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(width: 3),
              IconButton(
                tooltip: 'Supprimer $label',
                visualDensity: VisualDensity.compact,
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 15),
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineEmptyHistory extends StatelessWidget {
  const _InlineEmptyHistory({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSearchTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceObsidian.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.brandGold),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Vos recherches apparaîtront ici pour les retrouver rapidement.',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryLoading extends StatelessWidget {
  const _DiscoveryLoading({required this.responsive});

  final ResponsiveValues responsive;

  @override
  Widget build(BuildContext context) {
    return ShimmerGrid(
      itemCount: responsive.posterColumns * 2,
      crossAxisCount: responsive.posterColumns,
      spacing: responsive.gridGap,
      padding: EdgeInsets.zero,
    );
  }
}

class _InlineCatalogError extends StatelessWidget {
  const _InlineCatalogError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _InlineMessage(
      icon: Icons.cloud_off_rounded,
      message: 'Les tendances ne peuvent pas être chargées.',
      actionLabel: 'Réessayer',
      onAction: onRetry,
    );
  }
}

class _InlineCatalogEmpty extends StatelessWidget {
  const _InlineCatalogEmpty({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _InlineMessage(
      icon: Icons.movie_filter_outlined,
      message: 'Le catalogue est vide pour le moment.',
      actionLabel: 'Actualiser',
      onAction: onRetry,
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.brandGoldLight),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: AppTextStyles.bodyMedium)),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

List<_SearchItem> _catalogItems(
  List<FilmEntity> films,
  List<SeriesEntity> series,
) {
  return [
    ...films.map(_SearchItem.fromFilm),
    ...series.map(_SearchItem.fromSeries),
  ];
}

bool _recentlyAdded(DateTime date) {
  if (date.millisecondsSinceEpoch <= 0) return false;
  final age = DateTime.now().difference(date).inDays;
  return age >= 0 && age <= 45;
}
