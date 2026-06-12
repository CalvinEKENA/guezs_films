import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'package:guezs_films/features/auth/presentation/pages/splash_page.dart';
import 'package:guezs_films/features/auth/presentation/pages/onboarding_page.dart';
import 'package:guezs_films/features/auth/presentation/pages/login_page.dart';
import 'package:guezs_films/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:guezs_films/features/home/presentation/pages/home_page.dart';
import 'package:guezs_films/features/legal/presentation/pages/privacy_policy_page.dart';
import 'package:guezs_films/features/legal/presentation/pages/support_page.dart';
import 'package:guezs_films/features/legal/presentation/pages/terms_of_use_page.dart';
import 'package:guezs_films/features/search/presentation/pages/search_page.dart';
import 'package:guezs_films/features/favorites/presentation/pages/favorites_page.dart';
import 'package:guezs_films/features/downloads/presentation/pages/downloads_page.dart';
import 'package:guezs_films/features/profile/presentation/pages/profile_page.dart';
import 'package:guezs_films/features/details/presentation/pages/details_page.dart';
import 'package:guezs_films/features/player/presentation/pages/player_page.dart';
import 'package:guezs_films/features/player/presentation/pages/watch_episode_page.dart';
import 'package:guezs_films/features/player/presentation/pages/watch_film_page.dart';
import 'package:guezs_films/features/series/presentation/pages/series_details_page.dart';
import 'package:guezs_films/core/widgets/main_scaffold.dart';
import 'package:guezs_films/core/widgets/premium_states.dart';
import 'package:guezs_films/core/routes/route_constants.dart';
import 'package:guezs_films/core/theme/app_colors.dart';
import 'package:guezs_films/features/profile/presentation/pages/profile_selector_page.dart';

/// App Router Configuration
/// Handles all navigation with go_router
final routerProvider = Provider<GoRouter>((ref) {
  // Use a ValueNotifier to notify GoRouter of updates without rebuilding the provider
  final authStateNotifier = ValueNotifier<AsyncValue<UserEntity?>>(
    const AsyncValue.loading(),
  );

  // Listen to auth state changes and update the notifier
  ref.onDispose(authStateNotifier.dispose);
  ref.listen<AsyncValue<UserEntity?>>(
    authStateProvider,
    (_, next) => authStateNotifier.value = next,
  );

  return GoRouter(
    navigatorKey: AppRouter.rootNavigatorKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      final authState = authStateNotifier.value;
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final user = authState.valueOrNull;

      if (isLoading || hasError) return null;

      final path = state.uri.path;
      final isAuthRoute =
          path == Routes.login ||
          path == Routes.forgotPassword ||
          path == Routes.onboarding ||
          path == Routes.splash;
      final isProfileSelector = path == Routes.profileSelector;
      final isWatchRoute = path.startsWith('${Routes.watch}/');
      final isPublicInformationRoute =
          path == Routes.support ||
          path == Routes.privacyPolicy ||
          path == Routes.termsOfUse;

      if (user == null) {
        // Non connecté → login (sauf si déjà sur une route auth)
        return isAuthRoute ||
                isProfileSelector ||
                isWatchRoute ||
                isPublicInformationRoute
            ? null
            : Routes.login;
      }

      // Connecté + route auth → sélecteur de profil
      if (isAuthRoute) return Routes.profileSelector;

      return null;
    },
    routes: AppRouter.routes,
    errorBuilder: AppRouter.errorBuilder,
  );
});

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavigatorKey = GlobalKey<NavigatorState>();

  static final routes = [
    // ─────────────────────────────────────────────────────────────────────
    // Auth Flow Routes (Outside shell)
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: Routes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    GoRoute(
      path: Routes.login,
      name: 'login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    GoRoute(
      path: Routes.forgotPassword,
      name: 'forgot-password',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ForgotPasswordPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // Profile Selector (shown after login, before entering the app)
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: Routes.profileSelector,
      name: 'profile-selector',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProfileSelectorPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),

    GoRoute(
      path: Routes.support,
      name: 'support',
      builder: (context, state) => const SupportPage(),
    ),

    GoRoute(
      path: Routes.privacyPolicy,
      name: 'privacy-policy',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),

    GoRoute(
      path: Routes.termsOfUse,
      name: 'terms-of-use',
      builder: (context, state) => const TermsOfUsePage(),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // Main App Shell (Bottom Navigation)
    // ─────────────────────────────────────────────────────────────────────
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: Routes.home,
          name: 'home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePage()),
        ),

        GoRoute(
          path: Routes.search,
          name: 'search',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SearchPage()),
        ),

        GoRoute(
          path: Routes.favorites,
          name: 'favorites',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: FavoritesPage()),
        ),

        GoRoute(
          path: Routes.downloads,
          name: 'downloads',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DownloadsPage()),
        ),

        GoRoute(
          path: Routes.profile,
          name: 'profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfilePage()),
        ),
      ],
    ),

    // ─────────────────────────────────────────────────────────────────────
    // Detail & Player Routes (Full screen, outside shell)
    // ─────────────────────────────────────────────────────────────────────
    GoRoute(
      path: '${Routes.film}/:id',
      name: 'film-details',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: DetailsPage(filmId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),

    GoRoute(
      path: '${Routes.series}/:id',
      name: 'series-details',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: SeriesDetailsPage(seriesId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),

    GoRoute(
      path: Routes.watchFilm,
      name: 'watch-film',
      pageBuilder: (context, state) {
        final filmId = state.pathParameters['filmId'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: WatchFilmPage(filmId: filmId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),

    GoRoute(
      path: Routes.watchEpisode,
      name: 'watch-episode',
      pageBuilder: (context, state) {
        final seriesId = state.pathParameters['seriesId'] ?? '';
        final seasonId = state.pathParameters['seasonId'] ?? '';
        final episodeId = state.pathParameters['episodeId'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: WatchEpisodePage(
            seriesId: seriesId,
            seasonId: seasonId,
            episodeId: episodeId,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),

    // Deprecated legacy player route.
    // Keep temporarily for local downloads and old links that still transport
    // a video URL. Product playback must use the refresh-safe /watch routes.
    GoRoute(
      path: Routes.player,
      name: 'player',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final query = state.uri.queryParameters;
        return CustomTransitionPage(
          key: state.pageKey,
          child: PlayerPage(
            videoUrl:
                extra['videoUrl'] as String? ??
                query['url'] ??
                query['videoUrl'] ??
                '',
            title: extra['title'] as String? ?? query['title'] ?? '',
            posterUrl: extra['posterUrl'] as String? ?? query['posterUrl'],
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
  ];

  static Widget errorBuilder(BuildContext context, GoRouterState state) =>
      Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: PremiumEmptyState(
            icon: Icons.explore_off_rounded,
            title: 'Cette page n’est pas disponible',
            message:
                'Le lien est peut-être incomplet ou le contenu a été déplacé.',
            actionLabel: 'Retour à l’accueil',
            onAction: () => context.go(Routes.home),
          ),
        ),
      );
}
