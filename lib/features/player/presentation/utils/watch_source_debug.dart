import 'package:flutter/foundation.dart';

import '../../../access/domain/entities/watch_access_result.dart';
import '../../domain/services/mvp_playback_fallback.dart';

void debugWatchSourceDecision({
  required String contentId,
  required WatchAccessResult? access,
  required String directVideoUrl,
}) {
  if (!kDebugMode) return;

  final playbackUrl = access?.playbackUrl?.trim() ?? '';
  debugPrint(
    '[WatchSource] '
    'contentId=$contentId '
    'access.allowed=${access?.allowed} '
    'access.status=${access?.status.name ?? 'null'} '
    'access.playbackUrl=${playbackUrl.isEmpty ? 'empty' : 'present'} '
    'direct.videoUrl=${directVideoUrl.trim().isEmpty ? 'empty' : 'present'} '
    'fallbackMvpActive=$isDirectVideoFallbackEnabledForMvp',
  );
}
