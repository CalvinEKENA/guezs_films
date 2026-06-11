import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'package:guezs_films_site/features/auth/presentation/pages/splash_page.dart';
import 'package:guezs_films_site/features/auth/presentation/pages/onboarding_page.dart';
import 'package:guezs_films_site/features/auth/presentation/pages/login_page.dart';
import 'package:guezs_films_site/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:guezs_films_site/features/home/presentation/pages/home_page.dart';
import 'package:guezs_films_site/features/search/presentation/pages/search_page.dart';
import 'package:guezs_films_site/features/favorites/presentation/pages/favorites_page.dart';
import 'package:guezs_films_site/features/downloads/presentation/pages/downloads_page.dart';
import 'package:guezs_films_site/features/profile/presentation/pages/profile_page.dart';
import 'package:guezs_films_site/features/details/presentation/pages/details_page.dart';
import 'package:guezs_films_site/features/player/presentation/pages/player_page.dart';
import 'package:guezs_films_site/features/series/presentation/pages/series_details_page.dart';
import 'package:guezs_films_site/core/widgets/main_scaffold.dart';
import 'package:guezs_films_site/core/routes/route_constants.dart';
import 'package:guezs_films_site/features/profile/presentation/pages/profile_selector_page.dart';

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
    debugLogDiagnostics: true,
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      final authState = authStateNotifier.value;
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final user = authState.valueOrNull;

      if (isLoading || hasError) return null;

      final path = state.uri.path;
      final isAuthRoute = path == Routes.login ||
          path == Routes.forgotPassword ||
          path == Routes.onboarding ||
          path == Routes.splash;
      final isProfileSelector = path == Routes.profileSelector;

      if (user == null) {
        // Non connecté → login (sauf si déjà sur une route auth)
        return isAuthRoute || isProfileSelector ? null : Routes.login;
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
      path: Routes.player,
      name: 'player',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return CustomTransitionPage(
          key: state.pageKey,
          child: PlayerPage(
            videoUrl: extra['videoUrl'] as String? ?? '',
            title: extra['title'] as String? ?? '',
            posterUrl: extra['posterUrl'] as String?,
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(Routes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
}
