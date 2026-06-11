import '../../../player/domain/entities/player_content_request.dart';
import '../entities/watch_access_result.dart';

abstract class WatchAccessRepository {
  Future<WatchAccessResult> createWatchSession(PlayerContentRequest request);

  Future<WatchAccessResult> validateAccessCode({
    required PlayerContentRequest request,
    required String code,
  });

  Future<WatchAccessResult> getSignedVideoUrl({
    required PlayerContentRequest request,
    required String sessionId,
  });
}
