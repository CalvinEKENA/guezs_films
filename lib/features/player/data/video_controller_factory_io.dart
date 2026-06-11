import 'dart:io';

import 'package:video_player/video_player.dart';

class VideoControllerFactory {
  const VideoControllerFactory._();

  static VideoPlayerController create(String source) {
    if (_isLocalPath(source)) {
      if (source.startsWith('file://')) {
        return VideoPlayerController.file(File.fromUri(Uri.parse(source)));
      }
      return VideoPlayerController.file(File(source));
    }

    return VideoPlayerController.networkUrl(Uri.parse(source));
  }

  static bool _isLocalPath(String source) {
    return source.startsWith('/') ||
        source.startsWith('file://') ||
        source.contains(r':\');
  }
}
