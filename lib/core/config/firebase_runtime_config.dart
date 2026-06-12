class FirebaseRuntimeConfig {
  const FirebaseRuntimeConfig._();

  static const firebaseProjectId = 'guezs-films';
  static const functionsRegion = 'us-central1';

  /// Temporary MVP escape hatch for environments where access Functions are
  /// not deployed yet. Disable with:
  /// `--dart-define=ALLOW_DIRECT_VIDEO_FALLBACK_MVP=false`
  ///
  /// This must be removed once access rules and signed playback URLs are live.
  static const allowDirectVideoFallbackForMvp = bool.fromEnvironment(
    'ALLOW_DIRECT_VIDEO_FALLBACK_MVP',
    defaultValue: true,
  );
}
