import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_card.dart';

/// Custom video player page with controls and multi-track support
class PlayerPage extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? posterUrl;

  const PlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
    this.posterUrl,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isLocked = false;
  double _playbackSpeed = 1.0;
  String _selectedAudioTrack = 'Français (Original)';
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    // Force landscape and hide system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _initializePlayer() async {
    final videoPath = widget.videoUrl.isNotEmpty 
        ? widget.videoUrl 
        : 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4';

    // Sur Web, on utilise toujours networkUrl
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoPath));

    try {
      await _controller.initialize();
      _controller.addListener(_videoListener);

      setState(() {
        _isInitialized = true;
        _duration = _controller.value.duration;
      });

      // Auto-play
      _controller.play();
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _videoListener() {
    if (!mounted) return;

    setState(() {
      _isPlaying = _controller.value.isPlaying;
      _isBuffering = _controller.value.isBuffering;
      _position = _controller.value.position;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    // Restore orientation and system UI
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _seekForward() {
    if (_isLocked) return;
    final newPosition = _position + const Duration(seconds: AppConstants.doubleTapSeek);
    _controller.seekTo(newPosition);
  }

  void _seekBackward() {
    if (_isLocked) return;
    final newPosition = _position - const Duration(seconds: AppConstants.doubleTapSeek);
    _controller.seekTo(newPosition.isNegative ? Duration.zero : newPosition);
  }

  void _onTapScreen() {
    if (_isLocked) {
      setState(() => _showControls = !_showControls);
      return;
    }

    setState(() => _showControls = !_showControls);

    // Auto-hide controls after delay
    if (_showControls && _isPlaying) {
      Future.delayed(AppConstants.playerControlsHideDelay, () {
        if (mounted && _isPlaying && !_isLocked) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
      if (_isLocked) _showControls = false;
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        // Sur Web, on laisse le navigateur gérer l'orientation si possible
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitUp,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTapScreen,
        onDoubleTapDown: (details) {
          if (_isLocked) return;
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _seekBackward();
          } else {
            _seekForward();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            if (_isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              _buildLoadingPlaceholder(),

            // Buffering indicator
            if (_isBuffering)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),

            // Controls overlay
            if (!_isLocked)
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: _buildControlsOverlay(),
              )
            else
              _buildLockedOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Chargement...',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: GestureDetector(
            onTap: _toggleLock,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 1),
              ),
              child: const Icon(Icons.lock_open, color: AppColors.accent, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
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
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title,
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Lock Button
          IconButton(
            icon: const Icon(Icons.lock_outline, color: Colors.white),
            onPressed: _toggleLock,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettings,
          ),
          IconButton(
            icon: const Icon(Icons.cast, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    ).animate(target: _showControls ? 1 : 0).fadeIn(duration: 200.ms);
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.replay_10, color: Colors.white),
          onPressed: _seekBackward,
        ),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20),
              ],
            ),
            child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 48),
          ),
        ),
        const SizedBox(width: 32),
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.forward_10, color: Colors.white),
          onPressed: _seekForward,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgressBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position), style: AppTextStyles.caption.copyWith(color: Colors.white)),
                Text(_formatDuration(_duration), style: AppTextStyles.caption.copyWith(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.volume_up, color: Colors.white, size: 20), onPressed: () {}),
              const Spacer(),
              // Speed selector
              TextButton(
                onPressed: _showSpeedSelector,
                child: Text('${_playbackSpeed}x', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
              ),
              // Multi-Audio Tracks
              IconButton(
                icon: const Icon(Icons.audiotrack, color: Colors.white, size: 20),
                onPressed: _showAudioTrackSelector,
              ),
              IconButton(icon: const Icon(Icons.subtitles, color: Colors.white, size: 20), onPressed: () {}),
              IconButton(icon: const Icon(Icons.hd, color: Colors.white, size: 20), onPressed: _showQualitySelector),
              IconButton(
                icon: Icon(
                  _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _toggleFullscreen,
              ),
            ],
          ),
        ],
      ),
    ).animate(target: _showControls ? 1 : 0).fadeIn(duration: 200.ms);
  }

  Widget _buildProgressBar() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
        thumbColor: AppColors.primary,
      ),
      child: Slider(
        value: _position.inMilliseconds.toDouble(),
        min: 0,
        max: _duration.inMilliseconds.toDouble().clamp(1, double.infinity),
        onChanged: (value) {
          _controller.seekTo(Duration(milliseconds: value.toInt()));
        },
      ),
    );
  }

  void _showSpeedSelector() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: GlassCard(
          blur: 20,
          opacity: 0.1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text('Vitesse de lecture', style: AppTextStyles.titleMedium),
                ),
                ...speeds.map((speed) => ListTile(
                      dense: true,
                      title: Text('${speed}x', style: AppTextStyles.bodyMedium),
                      trailing: speed == _playbackSpeed
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _playbackSpeed = speed;
                          _controller.setPlaybackSpeed(speed);
                        });
                        Navigator.pop(ctx);
                      },
                    )),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAudioTrackSelector() {
    final tracks = ['Français (Original)', 'Anglais', 'Espagnol', 'Wolof'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: GlassCard(
          blur: 20,
          opacity: 0.1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text('Piste Audio (Langue)', style: AppTextStyles.titleMedium),
                ),
                ...tracks.map((track) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.audiotrack, color: AppColors.textTertiary),
                      title: Text(track, style: AppTextStyles.bodyMedium),
                      trailing: track == _selectedAudioTrack
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() => _selectedAudioTrack = track);
                        Navigator.pop(ctx);
                      },
                    )),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings() {
    _showAudioTrackSelector();
  }

  void _showQualitySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: GlassCard(
          blur: 20,
          opacity: 0.1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
                  child: Text('Qualité vidéo', style: AppTextStyles.titleMedium),
                ),
                ...AppConstants.videoQualities.map((quality) => ListTile(
                      dense: true,
                      title: Text(quality, style: AppTextStyles.bodyMedium),
                      trailing: quality == 'Auto'
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () => Navigator.pop(ctx),
                    )),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return '00:00';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
