import 'dart:io';

import 'package:video_player/video_player.dart';

class VideoControllerFactory {
  const VideoControllerFactory._();

  static VideoPlayerController create(String source) {
    final normalizedSource = source.trim();
    if (!isSupportedSource(normalizedSource)) {
      throw const FormatException('Unsupported video source');
    }

    if (_isLocalPath(normalizedSource)) {
      if (normalizedSource.startsWith('file://')) {
        return VideoPlayerController.file(
          File.fromUri(Uri.parse(normalizedSource)),
        );
      }
      return VideoPlayerController.file(File(normalizedSource));
    }

    final uri = Uri.parse(normalizedSource);
    return VideoPlayerController.networkUrl(uri, formatHint: _formatHint(uri));
  }

  static bool isSupportedSource(String source) {
    final normalizedSource = source.trim();
    if (normalizedSource.isEmpty) return false;
    if (_isLocalPath(normalizedSource)) return true;

    final uri = Uri.tryParse(normalizedSource);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  static bool _isLocalPath(String source) {
    return source.startsWith('/') ||
        source.startsWith('file://') ||
        source.contains(r':\');
  }

  static VideoFormat? _formatHint(Uri uri) {
    final path = uri.path.toLowerCase();
    if (path.endsWith('.m3u8')) return VideoFormat.hls;
    if (path.endsWith('.mpd')) return VideoFormat.dash;
    return null;
  }
}
