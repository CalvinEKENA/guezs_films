import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guezs_films/features/auth/presentation/providers/auth_providers.dart';
import 'package:guezs_films/features/auth/presentation/pages/splash_page.dart';
import 'package:guezs_films/features/auth/presentation/pages/onboarding_page.dart';
import 'package:guezs_films/features/auth/presentation/pages/login_page.dart';
import 'package:guezs_films/features/home/presentation/pages/home_page.dart';
import 'package:guezs_films/features/search/presentation/pages/search_page.dart';
import 'package:guezs_films/features/profile/presentation/pages/profile_page.dart';
import 'package:guezs_films/features/details/presentation/pages/details_page.dart';
import 'package:guezs_films/features/player/presentation/pages/player_page.dart';
import 'package:guezs_films/core/widgets/main_scaffold.dart';
import 'package:guezs_films/core/routes/route_constants.dart';

/// App Router Configuration
/// Handles all navigation with go_router
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: AppRouter.rootNavigatorKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final user = authState.valueOrNull;

      if (isLoading || hasError) return null;

      final isAuthRoute =
          state.uri.path == Routes.login ||
          state.uri.path == Routes.onboarding ||
          state.uri.path == Routes.splash;

      if (user == null) {
        // If not logged in and trying to access protected route, go to login
        return isAuthRoute ? null : Routes.onboarding;
      }

      // If logged in and on auth route, go home
      if (isAuthRoute) return Routes.home;

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
          path: Routes.downloads,
          name: 'downloads',
          pageBuilder: (context, state) => NoTransitionPage(
            child: Scaffold(
              body: Center(
                child: Text(
                  'Téléchargements',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ),
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
      path: '${Routes.movie}/:id',
      name: 'movie-details',
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return MaterialPage(
          key: state.pageKey,
          child: DetailsPage(contentId: id, contentType: ContentType.movie),
        );
      },
    ),

    GoRoute(
      path: '${Routes.series}/:id',
      name: 'series-details',
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return MaterialPage(
          key: state.pageKey,
          child: DetailsPage(contentId: id, contentType: ContentType.series),
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
