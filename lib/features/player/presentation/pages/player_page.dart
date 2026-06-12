import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/platform/platform_capabilities.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../data/player_fullscreen_controller.dart';
import '../../data/player_progress_store.dart';
import '../../data/video_controller_factory.dart';
import '../../domain/entities/player_content_request.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
    this.posterUrl,
    this.request,
  });

  final String videoUrl;
  final String title;
  final String? posterUrl;
  final PlayerContentRequest? request;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with WidgetsBindingObserver {
  final PlayerProgressStore _progressStore = const PlayerProgressStore();
  final FocusNode _keyboardFocusNode = FocusNode(debugLabel: 'player-keyboard');

  VideoPlayerController? _controller;
  Timer? _controlsTimer;
  Timer? _bufferingTimer;
  Timer? _seekFeedbackTimer;

  bool _isInitialized = false;
  bool _showControls = true;
  bool _isPlaying = false;
  bool _showBuffering = false;
  bool _isLocked = false;
  bool _isMuted = false;
  bool _isFullscreen = false;
  bool _isCompleted = false;
  bool _isScrubbing = false;
  bool _isSheetOpen = false;
  bool _awaitingResumeChoice = false;
  bool _didApplyPlaybackSystemMode = false;
  bool _disposed = false;

  double _playbackSpeed = 1;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _scrubPosition = Duration.zero;
  Duration? _resumePosition;

  String? _errorTitle;
  String? _errorMessage;
  String? _seekFeedback;
  int _initializationGeneration = 0;
  int _lastPositionBucket = -1;
  int _lastSavedSecond = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initializePlayer());
  }

  @override
  void didUpdateWidget(covariant PlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl ||
        oldWidget.request != widget.request) {
      unawaited(
        _saveProgress(
          request: oldWidget.request,
          position: _position,
          duration: _duration,
        ),
      );
      unawaited(_initializePlayer());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(_saveCurrentProgress());
      unawaited(_controller?.pause());
    }
  }

  Future<void> _initializePlayer() async {
    final generation = ++_initializationGeneration;
    _cancelTransientTimers();
    await _disposeController();

    if (_disposed || generation != _initializationGeneration) return;
    _setState(() {
      _isInitialized = false;
      _showControls = true;
      _isPlaying = false;
      _showBuffering = false;
      _isCompleted = false;
      _awaitingResumeChoice = false;
      _resumePosition = null;
      _position = Duration.zero;
      _duration = Duration.zero;
      _errorTitle = null;
      _errorMessage = null;
    });

    final source = widget.videoUrl.trim();
    if (source.isEmpty) {
      _setPlaybackError(
        title: 'Vidéo indisponible',
        message: 'Aucune source de lecture n’est configurée pour ce contenu.',
      );
      return;
    }
    if (!VideoControllerFactory.isSupportedSource(source)) {
      _setPlaybackError(
        title: 'Source vidéo indisponible',
        message: 'Cette adresse vidéo ne peut pas être lue sur cet appareil.',
      );
      return;
    }

    VideoPlayerController? controller;
    try {
      await _enterPlaybackSystemMode();
      controller = VideoControllerFactory.create(source);
      await controller.initialize();

      if (_disposed || generation != _initializationGeneration) {
        await controller.dispose();
        return;
      }

      _controller = controller;
      controller.addListener(_videoListener);
      _setState(() {
        _isInitialized = true;
        _duration = controller!.value.duration;
        _position = controller.value.position;
        _isPlaying = controller.value.isPlaying;
      });

      final request = widget.request;
      final resumePosition = request == null
          ? null
          : await _progressStore.load(
              request,
              duration: controller.value.duration,
            );

      if (_disposed || generation != _initializationGeneration) return;
      if (resumePosition != null) {
        _setState(() {
          _resumePosition = resumePosition;
          _awaitingResumeChoice = true;
          _showControls = true;
        });
      } else {
        await _play();
      }
    } catch (error) {
      debugPrint('Player initialization failed: $error');
      await controller?.dispose();
      if (_disposed || generation != _initializationGeneration) return;
      _setPlaybackError(
        title: _looksLikeNetworkError(error)
            ? 'Connexion interrompue'
            : 'Lecture indisponible',
        message: _looksLikeNetworkError(error)
            ? 'La vidéo ne peut pas être chargée. Vérifiez votre connexion puis réessayez.'
            : 'Ce format ou cette source vidéo n’est pas disponible pour le moment.',
      );
    }
  }

  void _videoListener() {
    if (_disposed) return;
    final controller = _controller;
    if (controller == null) return;
    final value = controller.value;

    if (value.hasError) {
      _setPlaybackError(
        title: 'Lecture interrompue',
        message:
            'La vidéo a rencontré un problème. Vérifiez votre connexion puis réessayez.',
      );
      return;
    }

    _updateBufferingState(value.isBuffering);

    final positionBucket = value.position.inMilliseconds ~/ 250;
    final completed =
        value.isCompleted ||
        (value.duration > Duration.zero &&
            value.position >=
                value.duration - const Duration(milliseconds: 500) &&
            !value.isPlaying);
    final stateChanged =
        positionBucket != _lastPositionBucket ||
        value.isPlaying != _isPlaying ||
        value.duration != _duration ||
        completed != _isCompleted;

    if (!stateChanged || _isScrubbing) return;
    _lastPositionBucket = positionBucket;

    if (completed && !_isCompleted) {
      _controlsTimer?.cancel();
      unawaited(_clearProgress());
    }

    _setState(() {
      _position = value.position;
      _duration = value.duration;
      _isPlaying = value.isPlaying;
      _isCompleted = completed;
      if (completed) _showControls = true;
    });

    final positionSecond = value.position.inSeconds;
    if (value.isPlaying &&
        positionSecond >= PlayerProgressStore.minimumResumePosition.inSeconds &&
        positionSecond - _lastSavedSecond >= 10) {
      _lastSavedSecond = positionSecond;
      unawaited(_saveCurrentProgress());
    }

    if (value.isPlaying && _showControls && !_isCompleted) {
      _scheduleControlsHide();
    }
  }

  void _updateBufferingState(bool isBuffering) {
    if (!isBuffering) {
      _bufferingTimer?.cancel();
      if (_showBuffering) _setState(() => _showBuffering = false);
      return;
    }

    if (_showBuffering || _bufferingTimer?.isActive == true) return;
    _bufferingTimer = Timer(const Duration(milliseconds: 350), () {
      if (!_disposed && _controller?.value.isBuffering == true) {
        _setState(() => _showBuffering = true);
      }
    });
  }

  Future<void> _play() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.play();
      if (_disposed) return;
      _setState(() {
        _isPlaying = true;
        _isCompleted = false;
      });
      _scheduleControlsHide();
    } catch (error) {
      _setPlaybackError(
        title: 'Lecture impossible',
        message:
            'La vidéo ne peut pas démarrer. Vérifiez votre connexion puis réessayez.',
      );
    }
  }

  Future<void> _pause() async {
    _controlsTimer?.cancel();
    await _controller?.pause();
    if (_disposed) return;
    _setState(() {
      _isPlaying = false;
      _showControls = true;
    });
    unawaited(_saveCurrentProgress());
  }

  void _togglePlayPause() {
    if (_awaitingResumeChoice) return;
    if (_isCompleted) {
      unawaited(_replay());
    } else if (_isPlaying) {
      unawaited(_pause());
    } else {
      unawaited(_play());
    }
  }

  Future<void> _resumePlayback() async {
    final resumePosition = _resumePosition;
    final controller = _controller;
    if (resumePosition == null || controller == null) return;

    _setState(() {
      _awaitingResumeChoice = false;
      _position = resumePosition;
    });
    await controller.seekTo(resumePosition);
    await _play();
  }

  Future<void> _startFromBeginning() async {
    _setState(() {
      _awaitingResumeChoice = false;
      _resumePosition = null;
      _position = Duration.zero;
    });
    await _clearProgress();
    await _controller?.seekTo(Duration.zero);
    await _play();
  }

  Future<void> _replay() async {
    _setState(() {
      _isCompleted = false;
      _position = Duration.zero;
      _showControls = true;
    });
    await _clearProgress();
    await _controller?.seekTo(Duration.zero);
    await _play();
  }

  void _seekBy(Duration offset) {
    if (_isLocked || _awaitingResumeChoice || _isCompleted) return;
    final controller = _controller;
    if (controller == null || _duration <= Duration.zero) return;

    final targetMilliseconds = (_position + offset).inMilliseconds.clamp(
      0,
      _duration.inMilliseconds,
    );
    final target = Duration(milliseconds: targetMilliseconds);
    unawaited(controller.seekTo(target));
    _setState(() {
      _position = target;
      _seekFeedback = offset.isNegative ? '-10 s' : '+10 s';
      _showControls = true;
    });
    _seekFeedbackTimer?.cancel();
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 650), () {
      if (!_disposed) _setState(() => _seekFeedback = null);
    });
    _scheduleControlsHide();
  }

  void _onTapScreen() {
    if (!_isInitialized ||
        _awaitingResumeChoice ||
        _isCompleted ||
        _errorMessage != null) {
      return;
    }

    if (_isLocked) {
      _setState(() => _showControls = true);
      _controlsTimer?.cancel();
      _controlsTimer = Timer(const Duration(seconds: 2), () {
        if (!_disposed && _isLocked) {
          _setState(() => _showControls = false);
        }
      });
      return;
    }

    _setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleControlsHide();
  }

  void _scheduleControlsHide() {
    _controlsTimer?.cancel();
    if (!_isPlaying ||
        !_showControls ||
        _isLocked ||
        _isSheetOpen ||
        _awaitingResumeChoice ||
        _isCompleted) {
      return;
    }
    _controlsTimer = Timer(AppConstants.playerControlsHideDelay, () {
      if (!_disposed &&
          _isPlaying &&
          !_isLocked &&
          !_isSheetOpen &&
          !_isCompleted) {
        _setState(() => _showControls = false);
      }
    });
  }

  void _toggleLock() {
    if (!PlatformCapabilities.isMobile) return;
    _controlsTimer?.cancel();
    _setState(() {
      _isLocked = !_isLocked;
      _showControls = !_isLocked;
    });
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null) return;
    final nextMuted = !_isMuted;
    unawaited(controller.setVolume(nextMuted ? 0 : 1));
    _setState(() => _isMuted = nextMuted);
  }

  bool get _canToggleFullscreen =>
      PlatformCapabilities.isMobile || PlayerFullscreenController.isSupported;

  Future<void> _toggleFullscreen() async {
    if (!_canToggleFullscreen) return;

    if (PlatformCapabilities.isMobile) {
      if (_isFullscreen) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } else {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
      if (!_disposed) _setState(() => _isFullscreen = !_isFullscreen);
      return;
    }

    final isFullscreen = await PlayerFullscreenController.toggle();
    if (!_disposed) _setState(() => _isFullscreen = isFullscreen);
  }

  Future<void> _enterPlaybackSystemMode() async {
    if (!PlatformCapabilities.isMobile || _didApplyPlaybackSystemMode) return;
    _didApplyPlaybackSystemMode = true;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!_disposed) _setState(() => _isFullscreen = true);
  }

  Future<void> _restoreSystemMode() async {
    await PlayerFullscreenController.exit();
    if (!PlatformCapabilities.isMobile || !_didApplyPlaybackSystemMode) return;

    _didApplyPlaybackSystemMode = false;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (PlatformCapabilities.shouldForcePortrait) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _isSheetOpen) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.space) {
      _togglePlayPause();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _seekBy(const Duration(seconds: -AppConstants.doubleTapSeek));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _seekBy(const Duration(seconds: AppConstants.doubleTapSeek));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyF && _canToggleFullscreen) {
      unawaited(_toggleFullscreen());
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_isFullscreen && !PlatformCapabilities.isMobile) {
        unawaited(_toggleFullscreen());
      } else if (_showControls) {
        _setState(() => _showControls = false);
      } else {
        unawaited(_exitPlayer());
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Future<void> _exitPlayer() async {
    await _controller?.pause();
    await _saveCurrentProgress();
    await _restoreSystemMode();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          unawaited(_saveCurrentProgress());
          unawaited(_restoreSystemMode());
        }
      },
      child: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onTapScreen,
            onDoubleTapDown: (details) {
              if (_isLocked) return;
              final screenWidth = MediaQuery.sizeOf(context).width;
              _seekBy(
                Duration(
                  seconds: details.globalPosition.dx < screenWidth / 2
                      ? -AppConstants.doubleTapSeek
                      : AppConstants.doubleTapSeek,
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Colors.black),
                if (_errorMessage != null)
                  _buildErrorState()
                else if (!_isInitialized || controller == null)
                  _buildLoadingState()
                else
                  _buildReadyPlayer(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadyPlayer(VideoPlayerController controller) {
    final aspectRatio = controller.value.aspectRatio > 0
        ? controller.value.aspectRatio
        : 16 / 9;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
        if (_showBuffering && !_isCompleted && !_awaitingResumeChoice)
          _buildBufferingIndicator(),
        if (_seekFeedback != null) _buildSeekFeedback(),
        if (_awaitingResumeChoice)
          _buildResumeState()
        else if (_isCompleted)
          _buildCompletedState()
        else if (_isLocked)
          _buildLockedOverlay()
        else
          _buildControlsOverlay(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return _PlayerBackdrop(
      posterUrl: widget.posterUrl,
      child: Center(
        child: _StatePanel(
          icon: Icons.play_circle_outline_rounded,
          title: 'Préparation de la séance',
          message: 'La vidéo arrive dans quelques instants.',
          loading: true,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return _PlayerBackdrop(
      posterUrl: widget.posterUrl,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 12,
              top: 8,
              child: _ControlButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Retour',
                onPressed: _exitPlayer,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _StatePanel(
                  icon: Icons.videocam_off_outlined,
                  title: _errorTitle ?? 'Lecture indisponible',
                  message:
                      _errorMessage ??
                      'Cette vidéo ne peut pas être lue pour le moment.',
                  primaryLabel: 'Réessayer',
                  onPrimaryPressed: _initializePlayer,
                  secondaryLabel: 'Retour',
                  onSecondaryPressed: _exitPlayer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeState() {
    final resumePosition = _resumePosition ?? Duration.zero;
    return _PlayerBackdrop(
      posterUrl: widget.posterUrl,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _StatePanel(
            icon: Icons.history_rounded,
            title: 'Reprendre la séance',
            message:
                'Vous vous êtes arrêté à ${_formatDuration(resumePosition)}.',
            primaryLabel: 'Reprendre',
            onPrimaryPressed: _resumePlayback,
            secondaryLabel: 'Recommencer',
            onSecondaryPressed: _startFromBeginning,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedState() {
    return Container(
      color: Colors.black.withValues(alpha: 0.76),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _StatePanel(
              icon: Icons.check_circle_outline_rounded,
              title: 'Fin de la séance',
              message: 'Merci d’avoir regardé ${widget.title}.',
              primaryLabel: 'Revoir',
              onPrimaryPressed: _replay,
              secondaryLabel: 'Quitter',
              onSecondaryPressed: _exitPlayer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBufferingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCinemaDark.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.glassBorder(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brandGold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Connexion en cours…',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeekFeedback() {
    final backward = _seekFeedback?.startsWith('-') ?? false;
    return IgnorePointer(
      child: Align(
        alignment: backward ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.bgCinemaDark.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.glassBorder(0.24)),
            ),
            child: Text(
              _seekFeedback!,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return AnimatedOpacity(
      opacity: _showControls ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      child: IgnorePointer(
        ignoring: !_showControls,
        child: SafeArea(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: _ControlButton(
                icon: Icons.lock_open_rounded,
                tooltip: 'Déverrouiller les contrôles',
                emphasized: true,
                onPressed: _toggleLock,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return AnimatedOpacity(
      opacity: _showControls ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      child: IgnorePointer(
        ignoring: !_showControls,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.78),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.86),
              ],
              stops: const [0, 0.24, 0.66, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildCenterControls()),
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          _ControlButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Retour',
            onPressed: _exitPlayer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title.trim().isEmpty ? 'GUEZS FILMS' : widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Lecture en cours',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (PlatformCapabilities.isMobile) ...[
            const SizedBox(width: 8),
            _ControlButton(
              icon: Icons.lock_outline_rounded,
              tooltip: 'Verrouiller les contrôles',
              onPressed: _toggleLock,
            ),
          ],
          const SizedBox(width: 8),
          _ControlButton(
            icon: Icons.settings_rounded,
            tooltip: 'Réglages',
            onPressed: _showSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundPlayerButton(
          icon: Icons.replay_10_rounded,
          tooltip: 'Reculer de 10 secondes',
          onPressed: () =>
              _seekBy(const Duration(seconds: -AppConstants.doubleTapSeek)),
        ),
        const SizedBox(width: 30),
        _RoundPlayerButton(
          icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          tooltip: _isPlaying ? 'Pause' : 'Lecture',
          primary: true,
          onPressed: _togglePlayPause,
        ),
        const SizedBox(width: 30),
        _RoundPlayerButton(
          icon: Icons.forward_10_rounded,
          tooltip: 'Avancer de 10 secondes',
          onPressed: () =>
              _seekBy(const Duration(seconds: AppConstants.doubleTapSeek)),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder(0.22), width: 0.8),
      ),
      child: Column(
        children: [
          _buildProgressBar(),
          Row(
            children: [
              Text(
                _formatDuration(_displayPosition),
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '  /  ${_formatDuration(_duration)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: [
                      _BottomControl(
                        icon: _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        label: _isMuted ? 'Muet' : 'Son',
                        onPressed: _toggleMute,
                      ),
                      _BottomControl(
                        icon: Icons.speed_rounded,
                        label: '${_playbackSpeed}x',
                        onPressed: _showSpeedSelector,
                      ),
                      _BottomControl(
                        icon: Icons.audiotrack_rounded,
                        label: 'Audio',
                        available: false,
                        onPressed: () => _showComingSoon(
                          title: 'Pistes audio',
                          message:
                              'Le changement de langue audio sera activé avec les futurs flux multi-pistes.',
                        ),
                      ),
                      _BottomControl(
                        icon: Icons.subtitles_rounded,
                        label: 'Sous-titres',
                        available: false,
                        onPressed: () => _showComingSoon(
                          title: 'Sous-titres',
                          message:
                              'Les sous-titres seront disponibles lorsque les pistes du catalogue seront connectées au player.',
                        ),
                      ),
                      _BottomControl(
                        icon: Icons.high_quality_rounded,
                        label: 'Qualité',
                        available: false,
                        onPressed: () => _showComingSoon(
                          title: 'Qualité vidéo',
                          message:
                              'La qualité adaptative arrivera avec les manifests HLS ou DASH.',
                        ),
                      ),
                      _BottomControl(
                        icon: _isFullscreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        label: 'Plein écran',
                        available: _canToggleFullscreen,
                        onPressed: _canToggleFullscreen
                            ? _toggleFullscreen
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Duration get _displayPosition => _isScrubbing ? _scrubPosition : _position;

  Widget _buildProgressBar() {
    final maxMilliseconds = _duration.inMilliseconds <= 0
        ? 1.0
        : _duration.inMilliseconds.toDouble();
    final value = _displayPosition.inMilliseconds
        .toDouble()
        .clamp(0, maxMilliseconds)
        .toDouble();
    final buffered = _bufferedPosition.inMilliseconds
        .toDouble()
        .clamp(value, maxMilliseconds)
        .toDouble();

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3.5,
        activeTrackColor: AppColors.spotlightBlue,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
        secondaryActiveTrackColor: Colors.white.withValues(alpha: 0.32),
        thumbColor: AppColors.brandGold,
        overlayColor: AppColors.brandGold.withValues(alpha: 0.16),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 15),
      ),
      child: Slider(
        value: value,
        secondaryTrackValue: buffered,
        min: 0,
        max: maxMilliseconds,
        onChangeStart: (_) {
          _controlsTimer?.cancel();
          _setState(() {
            _isScrubbing = true;
            _scrubPosition = _position;
          });
        },
        onChanged: (nextValue) {
          _setState(
            () => _scrubPosition = Duration(milliseconds: nextValue.round()),
          );
        },
        onChangeEnd: (nextValue) {
          final target = Duration(milliseconds: nextValue.round());
          unawaited(_controller?.seekTo(target));
          _setState(() {
            _position = target;
            _isScrubbing = false;
          });
          _scheduleControlsHide();
        },
      ),
    );
  }

  Duration get _bufferedPosition {
    final buffered = _controller?.value.buffered;
    if (buffered == null || buffered.isEmpty) return _position;
    return buffered.last.end;
  }

  Future<void> _showSpeedSelector() async {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    await _openSheet(
      builder: (sheetContext) => _PlayerSheet(
        title: 'Vitesse de lecture',
        subtitle: 'Ajustez le rythme sans modifier la qualité.',
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: speeds
              .map(
                (speed) => ChoiceChip(
                  label: Text('${speed}x'),
                  selected: speed == _playbackSpeed,
                  showCheckmark: false,
                  selectedColor: AppColors.brandGold,
                  backgroundColor: AppColors.surfaceVariant,
                  side: BorderSide(
                    color: speed == _playbackSpeed
                        ? AppColors.brandGold
                        : AppColors.border,
                  ),
                  labelStyle: AppTextStyles.labelLarge.copyWith(
                    color: speed == _playbackSpeed
                        ? AppColors.textOnGold
                        : AppColors.textSecondary,
                  ),
                  onSelected: (_) {
                    _setPlaybackSpeed(speed);
                    Navigator.pop(sheetContext);
                  },
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> _showSettings() async {
    await _openSheet(
      builder: (sheetContext) => _PlayerSheet(
        title: 'Réglages de lecture',
        subtitle: 'Les options actives sont signalées clairement.',
        child: Column(
          children: [
            _SettingsRow(
              icon: Icons.speed_rounded,
              title: 'Vitesse',
              value: '${_playbackSpeed}x',
              onTap: () {
                Navigator.pop(sheetContext);
                unawaited(_showSpeedSelector());
              },
            ),
            _SettingsRow(
              icon: Icons.audiotrack_rounded,
              title: 'Pistes audio',
              value: 'Bientôt disponible',
              available: false,
            ),
            _SettingsRow(
              icon: Icons.subtitles_rounded,
              title: 'Sous-titres',
              value: 'Bientôt disponible',
              available: false,
            ),
            _SettingsRow(
              icon: Icons.high_quality_rounded,
              title: 'Qualité adaptative',
              value: 'Bientôt disponible',
              available: false,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showComingSoon({
    required String title,
    required String message,
  }) async {
    await _openSheet(
      builder: (sheetContext) => _PlayerSheet(
        title: title,
        subtitle: message,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.brandBlue.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: AppColors.brandGoldLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cette fonction n’est pas encore active.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openSheet({
    required Widget Function(BuildContext context) builder,
  }) async {
    _controlsTimer?.cancel();
    _setState(() {
      _isSheetOpen = true;
      _showControls = true;
    });
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      builder: builder,
    );
    if (_disposed) return;
    _setState(() => _isSheetOpen = false);
    _keyboardFocusNode.requestFocus();
    _scheduleControlsHide();
  }

  void _setPlaybackSpeed(double speed) {
    final controller = _controller;
    if (controller == null) return;
    _setState(() => _playbackSpeed = speed);
    unawaited(controller.setPlaybackSpeed(speed));
  }

  void _setPlaybackError({required String title, required String message}) {
    _cancelTransientTimers();
    if (_disposed) return;
    _setState(() {
      _errorTitle = title;
      _errorMessage = message;
      _isInitialized = false;
      _isPlaying = false;
      _showBuffering = false;
      _showControls = true;
    });
  }

  Future<void> _saveCurrentProgress() {
    return _saveProgress(
      request: widget.request,
      position: _position,
      duration: _duration,
    );
  }

  Future<void> _saveProgress({
    required PlayerContentRequest? request,
    required Duration position,
    required Duration duration,
  }) async {
    if (request == null) return;
    await _progressStore.save(request, position: position, duration: duration);
  }

  Future<void> _clearProgress() async {
    final request = widget.request;
    if (request != null) await _progressStore.clear(request);
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    controller.removeListener(_videoListener);
    try {
      await controller.pause();
    } catch (_) {
      // A failed platform controller can still be disposed safely.
    }
    await controller.dispose();
  }

  void _cancelTransientTimers() {
    _controlsTimer?.cancel();
    _bufferingTimer?.cancel();
    _seekFeedbackTimer?.cancel();
  }

  void _setState(VoidCallback update) {
    if (!_disposed && mounted) setState(update);
  }

  bool _looksLikeNetworkError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('network') ||
        text.contains('connection') ||
        text.contains('http') ||
        text.contains('socket') ||
        text.contains('timeout');
  }

  String _formatDuration(Duration duration) {
    final safeDuration = duration.isNegative ? Duration.zero : duration;
    final hours = safeDuration.inHours;
    final minutes = safeDuration.inMinutes.remainder(60);
    final seconds = safeDuration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _disposed = true;
    _initializationGeneration++;
    WidgetsBinding.instance.removeObserver(this);
    _cancelTransientTimers();
    _keyboardFocusNode.dispose();
    unawaited(_saveCurrentProgress());
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_videoListener);
      unawaited(controller.dispose());
    }
    _controller = null;
    unawaited(_restoreSystemMode());
    super.dispose();
  }
}

class _PlayerBackdrop extends StatelessWidget {
  const _PlayerBackdrop({required this.posterUrl, required this.child});

  final String? posterUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (posterUrl != null && posterUrl!.trim().isNotEmpty)
          Opacity(
            opacity: 0.28,
            child: CachedImage(
              imageUrl: posterUrl,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.zero,
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                AppColors.brandBlueDark.withValues(alpha: 0.46),
                Colors.black.withValues(alpha: 0.92),
              ],
              radius: 1.15,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
    this.primaryLabel,
    this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool loading;
  final String? primaryLabel;
  final FutureOr<void> Function()? onPrimaryPressed;
  final String? secondaryLabel;
  final FutureOr<void> Function()? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceObsidian.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder(0.32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.38),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 46,
                height: 46,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.brandGold,
                ),
              )
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.34),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.glassBorder(0.3)),
                ),
                child: Icon(icon, size: 32, color: AppColors.brandGoldLight),
              ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (primaryLabel != null && onPrimaryPressed != null) ...[
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => onPrimaryPressed!(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGold,
                    foregroundColor: AppColors.textOnGold,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(primaryLabel!),
                ),
              ),
            ],
            if (secondaryLabel != null && onSecondaryPressed != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => onSecondaryPressed!(),
                  child: Text(secondaryLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.emphasized = false,
  });

  final IconData icon;
  final String tooltip;
  final FutureOr<void> Function()? onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: emphasized
            ? AppColors.brandGold
            : AppColors.bgCinemaDark.withValues(alpha: 0.52),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed == null ? null : () => onPressed!(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 21,
              color: emphasized ? AppColors.textOnGold : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundPlayerButton extends StatelessWidget {
  const _RoundPlayerButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.primary = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final size = primary ? 74.0 : 54.0;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: primary
            ? AppColors.brandGold
            : Colors.black.withValues(alpha: 0.42),
        shape: CircleBorder(
          side: BorderSide(
            color: primary
                ? AppColors.brandGoldLight.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.32),
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: primary ? 42 : 30,
              color: primary ? AppColors.textOnGold : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomControl extends StatelessWidget {
  const _BottomControl({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.available = true,
  });

  final IconData icon;
  final String label;
  final FutureOr<void> Function()? onPressed;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.textPrimary : AppColors.textTertiary;
    return Tooltip(
      message: available ? label : '$label · Bientôt disponible',
      child: InkResponse(
        onTap: onPressed == null ? null : () => onPressed!(),
        radius: 26,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerSheet extends StatelessWidget {
  const _PlayerSheet({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 640),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: AppColors.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: AppColors.glassBorder(0.34))),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(title, style: AppTextStyles.titleLarge),
            const SizedBox(height: 5),
            Text(subtitle, style: AppTextStyles.bodySmall),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.value,
    this.available = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool available;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: available,
      onTap: available ? onTap : null,
      leading: Icon(
        icon,
        color: available ? AppColors.brandGoldLight : AppColors.textDisabled,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: available ? AppColors.textPrimary : AppColors.textTertiary,
        ),
      ),
      trailing: Text(
        value,
        style: AppTextStyles.labelMedium.copyWith(
          color: available ? AppColors.brandGoldLight : AppColors.textDisabled,
        ),
      ),
    );
  }
}
