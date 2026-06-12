import 'dart:js_interop';

import 'package:web/web.dart' as web;

class PlayerFullscreenController {
  const PlayerFullscreenController._();

  static bool get isSupported => web.document.fullscreenEnabled;
  static bool get isFullscreen => web.document.fullscreenElement != null;

  static Future<bool> toggle() async {
    if (!isSupported) return false;

    try {
      if (isFullscreen) {
        await web.document.exitFullscreen().toDart;
      } else {
        final element = web.document.documentElement;
        if (element == null) return false;
        await element.requestFullscreen().toDart;
      }
    } catch (_) {
      return isFullscreen;
    }

    return isFullscreen;
  }

  static Future<void> exit() async {
    if (!isFullscreen) return;
    try {
      await web.document.exitFullscreen().toDart;
    } catch (_) {
      // The browser can reject fullscreen changes outside a user gesture.
    }
  }
}
