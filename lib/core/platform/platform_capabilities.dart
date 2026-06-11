import 'package:flutter/foundation.dart';

class PlatformCapabilities {
  const PlatformCapabilities._();

  static bool get isWeb => kIsWeb;

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  static bool get isMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  static bool get isLinux =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktop => isWindows || isMacOS || isLinux;

  static bool get supportsDownloads => isMobile;

  static bool get supportsLocalVideoFiles => !isWeb;

  static bool get supportsAppleSignIn => isWeb || isIOS || isMacOS;

  static bool get supportsGoogleSignIn => isWeb || isAndroid || isIOS;

  static bool get shouldForcePortrait => isMobile;
}
