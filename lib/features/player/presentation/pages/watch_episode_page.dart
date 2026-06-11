import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/content_providers.dart';
import '../../../../core/routes/route_constants.dart';
import '../widgets/watch_state_view.dart';
import '../../domain/entities/player_content_request.dart';
import 'player_page.dart';

class WatchEpisodePage extends ConsumerWidget {
  const WatchEpisodePage({
    super.key,
    required this.seriesId,
    required this.seasonId,
    required this.episodeId,
  });

  final String seriesId;
  final String seasonId;
  final String episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = PlayerContentRequest.episode(
      seriesId: seriesId,
      seasonId: seasonId,
      episodeId: episodeId,
    );
    final episodeAsync = ref.watch(
      episodeDetailsProvider((
        seriesId: seriesId,
        seasonId: seasonId,
        episodeId: episodeId,
      )),
    );
    final seriesAsync = ref.watch(seriesDetailsProvider(seriesId));

    if (episodeAsync.isLoading || seriesAsync.isLoading) {
      return const WatchStateView.loading(
        title: 'Chargement de l’épisode',
        message: 'Préparation de la lecture...',
      );
    }

    if (episodeAsync.hasError) {
      return WatchStateView(
        icon: _iconForError(episodeAsync.error!),
        title: _titleForError(
          episodeAsync.error!,
          fallback: 'Impossible de charger cet épisode',
        ),
        message: _messageForError(
          episodeAsync.error!,
          notFound: 'Cet épisode est introuvable ou a été retiré du catalogue.',
          network: 'Vérifiez votre connexion puis réessayez.',
        ),
        primaryLabel: 'Retour à la série',
        onPrimaryPressed: () => context.go(Routes.seriesDetailsPath(seriesId)),
        secondaryLabel: 'Réessayer',
        onSecondaryPressed: () {
          ref
            ..invalidate(
              episodeDetailsProvider((
                seriesId: seriesId,
                seasonId: seasonId,
                episodeId: episodeId,
              )),
            )
            ..invalidate(seriesDetailsProvider(seriesId));
        },
      );
    }

    if (seriesAsync.hasError) {
      return WatchStateView(
        icon: _iconForError(seriesAsync.error!),
        title: _titleForError(
          seriesAsync.error!,
          fallback: 'Impossible de charger la série',
        ),
        message: _messageForError(
          seriesAsync.error!,
          notFound:
              'Cette série est introuvable ou a été retirée du catalogue.',
          network: 'Vérifiez votre connexion puis réessayez.',
        ),
        primaryLabel: 'Retour au catalogue',
        onPrimaryPressed: () => context.go(Routes.home),
        secondaryLabel: 'Réessayer',
        onSecondaryPressed: () =>
            ref.invalidate(seriesDetailsProvider(seriesId)),
      );
    }

    final episode = episodeAsync.value!;
    final series = seriesAsync.value!;
    if (episode.videoUrl.trim().isEmpty) {
      return WatchStateView(
        icon: Icons.videocam_off_outlined,
        title: 'Vidéo indisponible',
        message:
            'Cet épisode existe dans le catalogue, mais aucune source vidéo exploitable n’est configurée.',
        primaryLabel: 'Retour à la série',
        onPrimaryPressed: () => context.go(Routes.seriesDetailsPath(seriesId)),
        secondaryLabel: 'Catalogue',
        onSecondaryPressed: () => context.go(Routes.home),
      );
    }

    return PlayerPage(
      videoUrl: episode.videoUrl,
      title: episode.title,
      posterUrl: episode.thumbnailUrl.isNotEmpty
          ? episode.thumbnailUrl
          : series.posterUrl,
      request: request,
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
  if (_isNotFoundError(error)) return 'Épisode introuvable';
  return fallback;
}

String _messageForError(
  Object error, {
  required String notFound,
  required String network,
}) {
  if (_isPermissionError(error)) {
    return 'Votre session ne permet pas d’accéder à cet épisode pour le moment.';
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
