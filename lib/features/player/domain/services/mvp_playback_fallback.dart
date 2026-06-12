import '../../../../core/config/firebase_runtime_config.dart';
import '../../../access/domain/entities/watch_access_result.dart';

bool shouldUseDirectVideoFallback({
  required WatchAccessResult? access,
  required String directVideoUrl,
}) {
  return FirebaseRuntimeConfig.allowDirectVideoFallbackForMvp &&
      directVideoUrl.trim().isNotEmpty &&
      access?.allowsTemporaryMvpFallback == true;
}
