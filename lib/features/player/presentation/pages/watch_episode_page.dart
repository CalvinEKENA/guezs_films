import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/content_providers.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/widgets/promo_code_dialog.dart';
import '../../../access/domain/entities/watch_access_result.dart';
import '../../../access/presentation/providers/watch_access_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
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
    final authState = ref.watch(authStateProvider);

    if (authState.isLoading) {
      return const WatchStateView.loading(
        title: 'Vérification du compte',
        message: 'Contrôle de votre session...',
      );
    }

    if (authState.valueOrNull == null) {
      return WatchStateView(
        icon: Icons.lock_outline_rounded,
        title: 'Connexion requise',
        message:
            'Connectez-vous ou créez un compte pour demander un accès vidéo.',
        primaryLabel: 'Se connecter',
        onPrimaryPressed: () => context.go(Routes.login),
        secondaryLabel: 'Retour au catalogue',
        onSecondaryPressed: () => context.go(Routes.home),
      );
    }

    final episodeAsync = ref.watch(
      episodeDetailsProvider((
        seriesId: seriesId,
        seasonId: seasonId,
        episodeId: episodeId,
      )),
    );
    final seriesAsync = ref.watch(seriesDetailsProvider(seriesId));
    final accessAsync = ref.watch(watchAccessProvider(request));

    if (episodeAsync.isLoading ||
        seriesAsync.isLoading ||
        accessAsync.isLoading) {
      return const WatchStateView.loading(
        title: 'Vérification de l’accès',
        message: 'Préparation de votre session de lecture...',
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
    final access = accessAsync.valueOrNull;
    if (access == null || !access.allowed) {
      return _buildAccessState(
        context: context,
        ref: ref,
        request: request,
        result:
            access ??
            const WatchAccessResult(
              allowed: false,
              status: WatchAccessStatus.error,
              message: 'Impossible de vérifier l’accès vidéo.',
            ),
      );
    }

    final playbackUrl = _resolvePlaybackUrl(access, episode.videoUrl);
    if (playbackUrl.isEmpty) {
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
      videoUrl: playbackUrl,
      title: episode.title,
      posterUrl: episode.thumbnailUrl.isNotEmpty
          ? episode.thumbnailUrl
          : series.posterUrl,
      request: request,
    );
  }

  Widget _buildAccessState({
    required BuildContext context,
    required WidgetRef ref,
    required PlayerContentRequest request,
    required WatchAccessResult result,
  }) {
    if (result.requiresLogin) {
      return WatchStateView(
        icon: Icons.lock_outline_rounded,
        title: 'Connexion requise',
        message: result.message.isNotEmpty
            ? result.message
            : 'Connectez-vous pour demander un accès à cet épisode.',
        primaryLabel: 'Se connecter',
        onPrimaryPressed: () => context.go(Routes.login),
        secondaryLabel: 'Retour à la série',
        onSecondaryPressed: () =>
            context.go(Routes.seriesDetailsPath(seriesId)),
      );
    }

    final canEnterCode = result.requiresCode;
    return WatchStateView(
      icon: canEnterCode
          ? Icons.lock_open_rounded
          : Icons.error_outline_rounded,
      title: canEnterCode ? 'Accès requis' : 'Accès indisponible',
      message: result.message.isNotEmpty
          ? result.message
          : 'Cet épisode nécessite un accès valide.',
      primaryLabel: canEnterCode ? 'Débloquer l’accès' : 'Réessayer',
      onPrimaryPressed: canEnterCode
          ? () => _showAccessDialog(context, ref, request)
          : () => ref.invalidate(watchAccessProvider(request)),
      secondaryLabel: 'Retour à la série',
      onSecondaryPressed: () => context.go(Routes.seriesDetailsPath(seriesId)),
    );
  }

  void _showAccessDialog(
    BuildContext context,
    WidgetRef ref,
    PlayerContentRequest request,
  ) {
    showPromoCodeDialog(
      context,
      request: request,
      onSuccess: (_) => ref.invalidate(watchAccessProvider(request)),
      onNoCode: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Un accès ou un code valide est nécessaire.'),
          ),
        );
      },
    );
  }

  String _resolvePlaybackUrl(WatchAccessResult access, String fallbackUrl) {
    final signedUrl = access.playbackUrl?.trim();
    if (signedUrl != null && signedUrl.isNotEmpty) return signedUrl;
    return fallbackUrl.trim();
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
