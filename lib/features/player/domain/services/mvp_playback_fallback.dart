import '../../../../core/config/firebase_runtime_config.dart';
import '../../../access/domain/entities/watch_access_result.dart';

bool get isDirectVideoFallbackEnabledForMvp =>
    FirebaseRuntimeConfig.allowDirectVideoFallbackForMvp;

bool shouldUseDirectVideoFallback({
  required WatchAccessResult? access,
  required String directVideoUrl,
}) {
  return isDirectVideoFallbackEnabledForMvp &&
      directVideoUrl.trim().isNotEmpty &&
      access?.allowsTemporaryMvpFallback == true;
}
