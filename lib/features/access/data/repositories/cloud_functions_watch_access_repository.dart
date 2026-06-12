import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/config/firebase_runtime_config.dart';
import '../../../player/domain/entities/player_content_request.dart';
import '../../domain/entities/watch_access_result.dart';
import '../../domain/repositories/watch_access_repository.dart';

class CloudFunctionsWatchAccessRepository implements WatchAccessRepository {
  const CloudFunctionsWatchAccessRepository(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<WatchAccessResult> createWatchSession(
    PlayerContentRequest request,
  ) async {
    return _callAccessFunction(
      name: 'createWatchSession',
      payload: {'request': _requestPayload(request)},
    );
  }

  @override
  Future<WatchAccessResult> validateAccessCode({
    required PlayerContentRequest request,
    required String code,
  }) async {
    return _callAccessFunction(
      name: 'validateAccessCode',
      payload: {'code': code.trim(), 'request': _requestPayload(request)},
    );
  }

  @override
  Future<WatchAccessResult> getSignedVideoUrl({
    required PlayerContentRequest request,
    required String sessionId,
  }) async {
    return _callAccessFunction(
      name: 'getSignedVideoUrl',
      payload: {'sessionId': sessionId, 'request': _requestPayload(request)},
    );
  }

  Future<WatchAccessResult> _callAccessFunction({
    required String name,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable.call<Map<String, dynamic>>(payload);
      return WatchAccessResult.fromMap(Map<String, dynamic>.from(result.data));
    } on FirebaseFunctionsException catch (error) {
      if (kDebugMode) {
        debugPrint(
          'Firebase callable $name failed on '
          '${FirebaseRuntimeConfig.firebaseProjectId}/'
          '${FirebaseRuntimeConfig.functionsRegion}: ${error.code}',
        );
      }
      return WatchAccessResult.failure(
        status: WatchAccessFunctionErrorMapper.statusForCode(error.code),
        message: WatchAccessFunctionErrorMapper.messageForCode(error.code),
      );
    } catch (_) {
      return WatchAccessResult.failure(
        status: WatchAccessStatus.error,
        message: 'Impossible de vérifier l’accès vidéo pour le moment.',
      );
    }
  }

  Map<String, dynamic> _requestPayload(PlayerContentRequest request) {
    return {
      'contentType': request.contentType.name,
      if (request.filmId != null) 'filmId': request.filmId,
      if (request.seriesId != null) 'seriesId': request.seriesId,
      if (request.seasonId != null) 'seasonId': request.seasonId,
      if (request.episodeId != null) 'episodeId': request.episodeId,
    };
  }
}

class WatchAccessFunctionErrorMapper {
  const WatchAccessFunctionErrorMapper._();

  static WatchAccessStatus statusForCode(String code) {
    switch (code) {
      case 'unauthenticated':
        return WatchAccessStatus.guest;
      case 'permission-denied':
        return WatchAccessStatus.denied;
      case 'failed-precondition':
        return WatchAccessStatus.codeRequired;
      case 'not-found':
        return WatchAccessStatus.serviceNotDeployed;
      case 'unavailable':
      case 'internal':
      case 'deadline-exceeded':
        return WatchAccessStatus.unavailable;
      default:
        return WatchAccessStatus.error;
    }
  }

  static String messageForCode(String code) {
    switch (code) {
      case 'not-found':
        return 'Le service d’accès vidéo n’est pas encore déployé sur '
            'Firebase. Déployez les Cloud Functions ou activez le mode MVP.';
      case 'unavailable':
        return 'Le service d’accès vidéo est momentanément indisponible.';
      case 'permission-denied':
        return 'Votre compte n’est pas autorisé à accéder à ce contenu.';
      case 'unauthenticated':
        return 'Connectez-vous pour demander un accès vidéo.';
      case 'failed-precondition':
        return 'Ce contenu nécessite un code ou un accès valide.';
      case 'internal':
        return 'Le service d’accès vidéo a rencontré un problème temporaire.';
      case 'deadline-exceeded':
        return 'La vérification de l’accès prend trop de temps. Réessayez.';
      default:
        return 'Impossible de vérifier l’accès vidéo pour le moment.';
    }
  }
}
