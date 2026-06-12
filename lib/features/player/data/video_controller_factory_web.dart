import 'package:video_player/video_player.dart';

class VideoControllerFactory {
  const VideoControllerFactory._();

  static VideoPlayerController create(String source) {
    final normalizedSource = source.trim();
    if (!isSupportedSource(normalizedSource)) {
      throw const FormatException('Unsupported video source');
    }

    if (_isLocalPath(normalizedSource)) {
      throw UnsupportedError(
        'La lecture de fichiers locaux n est pas disponible sur Web.',
      );
    }

    return VideoPlayerController.networkUrl(Uri.parse(normalizedSource));
  }

  static bool isSupportedSource(String source) {
    final normalizedSource = source.trim();
    if (normalizedSource.isEmpty || _isLocalPath(normalizedSource)) {
      return false;
    }

    final uri = Uri.tryParse(normalizedSource);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'blob');
  }

  static bool _isLocalPath(String source) {
    return source.startsWith('/') ||
        source.startsWith('file://') ||
        source.contains(r':\');
  }
}
