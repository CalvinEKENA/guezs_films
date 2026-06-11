import 'package:cloud_functions/cloud_functions.dart';

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
      return WatchAccessResult.failure(
        status: _statusForFunctionCode(error.code),
        message: error.message ?? 'Accès vidéo indisponible pour le moment.',
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

  WatchAccessStatus _statusForFunctionCode(String code) {
    switch (code) {
      case 'unauthenticated':
        return WatchAccessStatus.guest;
      case 'permission-denied':
        return WatchAccessStatus.denied;
      case 'failed-precondition':
        return WatchAccessStatus.codeRequired;
      case 'unavailable':
        return WatchAccessStatus.unavailable;
      default:
        return WatchAccessStatus.error;
    }
  }
}
