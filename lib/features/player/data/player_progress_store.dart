import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/entities/player_content_request.dart';

class PlayerProgressStore {
  const PlayerProgressStore();

  static const String _keyPrefix = 'player_progress_v1:';
  static const Duration minimumResumePosition = Duration(seconds: 30);

  Future<Duration?> load(
    PlayerContentRequest request, {
    required Duration duration,
  }) async {
    if (duration <= Duration.zero) return null;

    final preferences = await SharedPreferences.getInstance();
    final milliseconds = preferences.getInt(_keyFor(request));
    if (milliseconds == null || milliseconds <= 0) return null;

    final position = Duration(milliseconds: milliseconds);
    if (!_isResumePositionUseful(position: position, duration: duration)) {
      await preferences.remove(_keyFor(request));
      return null;
    }

    return position;
  }

  Future<void> save(
    PlayerContentRequest request, {
    required Duration position,
    required Duration duration,
  }) async {
    if (duration <= Duration.zero) return;

    final preferences = await SharedPreferences.getInstance();
    final key = _keyFor(request);
    if (!_isResumePositionUseful(position: position, duration: duration)) {
      await preferences.remove(key);
      return;
    }

    await preferences.setInt(key, position.inMilliseconds);
  }

  Future<void> clear(PlayerContentRequest request) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_keyFor(request));
  }

  String _keyFor(PlayerContentRequest request) {
    return '$_keyPrefix${request.storageKey}';
  }

  bool _isResumePositionUseful({
    required Duration position,
    required Duration duration,
  }) {
    if (position <= minimumResumePosition || position >= duration) {
      return false;
    }

    final remaining = duration - position;
    final watchedRatio = position.inMilliseconds / duration.inMilliseconds;
    return remaining >
            const Duration(seconds: AppConstants.resumeThresholdSeconds) &&
        watchedRatio < AppConstants.watchedThreshold;
  }
}
