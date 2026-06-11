import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:guezs_films/core/domain/entities/film_entity.dart';
import 'package:guezs_films/core/providers/content_providers.dart';
import 'package:guezs_films/core/routes/app_router.dart';
import 'package:guezs_films/core/routes/route_constants.dart';
import 'package:guezs_films/features/access/domain/entities/watch_access_result.dart';
import 'package:guezs_films/features/access/presentation/providers/watch_access_providers.dart';
import 'package:guezs_films/features/auth/domain/entities/user_entity.dart';
import 'package:guezs_films/features/auth/presentation/providers/auth_providers.dart';
import 'package:guezs_films/features/player/domain/entities/player_content_request.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // TODO: Add proper widget tests for Guezs Films
    expect(true, isTrue);
  });

  testWidgets('Watch film route is recognized without navigation extras', (
    tester,
  ) async {
    final pendingFilm = Completer<FilmEntity>();
    final pendingAccess = Completer<WatchAccessResult>();
    final request = PlayerContentRequest.film('test-id');
    final router = GoRouter(
      initialLocation: Routes.filmWatchPath('test-id'),
      routes: AppRouter.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const UserEntity(uid: 'test-user', email: 'test@example.com'),
            ),
          ),
          filmDetailsProvider(
            'test-id',
          ).overrideWith((ref) => pendingFilm.future),
          watchAccessProvider(
            request,
          ).overrideWith((ref) => pendingAccess.future),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();

    expect(find.text('Vérification de l’accès'), findsOneWidget);
  });
}
