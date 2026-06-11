import 'package:video_player/video_player.dart';

class VideoControllerFactory {
  const VideoControllerFactory._();

  static VideoPlayerController create(String source) {
    if (_isLocalPath(source)) {
      throw UnsupportedError(
        'La lecture de fichiers locaux n est pas disponible sur Web.',
      );
    }

    return VideoPlayerController.networkUrl(Uri.parse(source));
  }

  static bool _isLocalPath(String source) {
    return source.startsWith('/') ||
        source.startsWith('file://') ||
        source.contains(r':\');
  }
}
