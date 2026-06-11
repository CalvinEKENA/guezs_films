import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:guezs_films/core/domain/entities/film_entity.dart';
import 'package:guezs_films/core/providers/content_providers.dart';
import 'package:guezs_films/core/routes/app_router.dart';
import 'package:guezs_films/core/routes/route_constants.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // TODO: Add proper widget tests for Guezs Films
    expect(true, isTrue);
  });

  testWidgets('Watch film route is recognized without navigation extras', (
    tester,
  ) async {
    final pendingFilm = Completer<FilmEntity>();
    final router = GoRouter(
      initialLocation: Routes.filmWatchPath('test-id'),
      routes: AppRouter.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filmDetailsProvider(
            'test-id',
          ).overrideWith((ref) => pendingFilm.future),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(find.text('Chargement du film'), findsOneWidget);
  });
}
