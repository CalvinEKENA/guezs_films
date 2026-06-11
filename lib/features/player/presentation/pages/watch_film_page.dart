import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/content_providers.dart';
import '../../../../core/routes/route_constants.dart';
import '../widgets/watch_state_view.dart';
import '../../domain/entities/player_content_request.dart';
import 'player_page.dart';

class WatchFilmPage extends ConsumerWidget {
  const WatchFilmPage({super.key, required this.filmId});

  final String filmId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = PlayerContentRequest.film(filmId);
    final filmAsync = ref.watch(filmDetailsProvider(filmId));

    return filmAsync.when(
      loading: () => const WatchStateView.loading(
        title: 'Chargement du film',
        message: 'Préparation de la lecture...',
      ),
      error: (error, stackTrace) => WatchStateView(
        icon: _iconForError(error),
        title: _titleForError(error, fallback: 'Impossible de charger ce film'),
        message: _messageForError(
          error,
          notFound: 'Ce film est introuvable ou a été retiré du catalogue.',
          network: 'Vérifiez votre connexion puis réessayez.',
        ),
        primaryLabel: 'Retour au catalogue',
        onPrimaryPressed: () => context.go(Routes.home),
        secondaryLabel: 'Réessayer',
        onSecondaryPressed: () => ref.invalidate(filmDetailsProvider(filmId)),
      ),
      data: (film) {
        if (film.videoUrl.trim().isEmpty) {
          return WatchStateView(
            icon: Icons.videocam_off_outlined,
            title: 'Vidéo indisponible',
            message:
                'Ce film existe dans le catalogue, mais aucune source vidéo exploitable n’est configurée.',
            primaryLabel: 'Retour au film',
            onPrimaryPressed: () => context.go(Routes.filmDetailsPath(filmId)),
            secondaryLabel: 'Catalogue',
            onSecondaryPressed: () => context.go(Routes.home),
          );
        }

        return PlayerPage(
          videoUrl: film.videoUrl,
          title: film.title,
          posterUrl: film.posterUrl,
          request: request,
        );
      },
    );
  }
}

IconData _iconForError(Object error) {
  return _isPermissionError(error)
      ? Icons.lock_outline_rounded
      : Icons.error_outline_rounded;
}

String _titleForError(Object error, {required String fallback}) {
  if (_isPermissionError(error)) return 'Accès impossible';
  if (_isNotFoundError(error)) return 'Contenu introuvable';
  return fallback;
}

String _messageForError(
  Object error, {
  required String notFound,
  required String network,
}) {
  if (_isPermissionError(error)) {
    return 'Votre session ne permet pas d’accéder à ce contenu pour le moment.';
  }
  if (_isNotFoundError(error)) return notFound;
  return network;
}

bool _isPermissionError(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('permission-denied') ||
      text.contains('permission_denied') ||
      text.contains('unauthorized');
}

bool _isNotFoundError(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('introuvable') || text.contains('not-found');
}
