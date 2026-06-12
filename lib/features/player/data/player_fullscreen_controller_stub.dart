class PlayerFullscreenController {
  const PlayerFullscreenController._();

  static bool get isSupported => false;
  static bool get isFullscreen => false;

  static Future<bool> toggle() async => false;
  static Future<void> exit() async {}
}
