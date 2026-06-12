import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/content_providers.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/widgets/promo_code_dialog.dart';
import '../../../access/domain/entities/watch_access_result.dart';
import '../../../access/presentation/providers/watch_access_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/player_content_request.dart';
import '../../domain/services/mvp_playback_fallback.dart';
import '../widgets/watch_state_view.dart';
import 'player_page.dart';

class WatchFilmPage extends ConsumerWidget {
  const WatchFilmPage({super.key, required this.filmId});

  final String filmId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = PlayerContentRequest.film(filmId);
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

    final filmAsync = ref.watch(filmDetailsProvider(filmId));
    final accessAsync = ref.watch(watchAccessProvider(request));

    if (filmAsync.isLoading || accessAsync.isLoading) {
      return const WatchStateView.loading(
        title: 'Vérification de l’accès',
        message: 'Préparation de votre session de lecture...',
      );
    }

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
        final access = accessAsync.valueOrNull;
        final directVideoUrl = film.videoUrl.trim();
        if (shouldUseDirectVideoFallback(
          access: access,
          directVideoUrl: directVideoUrl,
        )) {
          if (kDebugMode) {
            debugPrint(
              'Temporary MVP direct-video fallback used for film $filmId.',
            );
          }
          return PlayerPage(
            videoUrl: directVideoUrl,
            title: film.title,
            posterUrl: film.posterUrl,
            request: request,
          );
        }

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

        final playbackUrl = _resolvePlaybackUrl(access, film.videoUrl);
        if (playbackUrl.isEmpty) {
          return WatchStateView(
            icon: Icons.videocam_off_outlined,
            title: 'Vidéo indisponible',
            message: 'Cette vidéo est momentanément indisponible.',
            primaryLabel: 'Retour au film',
            onPrimaryPressed: () => context.go(Routes.filmDetailsPath(filmId)),
            secondaryLabel: 'Catalogue',
            onSecondaryPressed: () => context.go(Routes.home),
          );
        }

        return PlayerPage(
          videoUrl: playbackUrl,
          title: film.title,
          posterUrl: film.posterUrl,
          request: request,
        );
      },
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
            : 'Connectez-vous pour demander un accès à ce film.',
        primaryLabel: 'Se connecter',
        onPrimaryPressed: () => context.go(Routes.login),
        secondaryLabel: 'Retour au film',
        onSecondaryPressed: () => context.go(Routes.filmDetailsPath(filmId)),
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
          : 'Ce contenu nécessite un accès valide.',
      primaryLabel: canEnterCode ? 'Débloquer l’accès' : 'Réessayer',
      onPrimaryPressed: canEnterCode
          ? () => _showAccessDialog(context, ref, request)
          : () => ref.invalidate(watchAccessProvider(request)),
      secondaryLabel: 'Retour au film',
      onSecondaryPressed: () => context.go(Routes.filmDetailsPath(filmId)),
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
