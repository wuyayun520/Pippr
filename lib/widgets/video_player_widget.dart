import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final String coverImagePath;
  final bool autoPlay;
  final Function(VideoPlayerController?)? onControllerReady;
  final VoidCallback? onTap; // 点击回调

  const VideoPlayerWidget({
    super.key,
    required this.videoPath,
    required this.coverImagePath,
    this.autoPlay = false,
    this.onControllerReady,
    this.onTap,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoPath);
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.autoPlay) {
          _controller!.play();
          setState(() {
            _isPlaying = true;
          });
        }
        _controller!.addListener(_videoListener);
        if (widget.onControllerReady != null && mounted) {
          widget.onControllerReady!(_controller);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      if (_controller!.value.position >= _controller!.value.duration) {
        setState(() {
          _isPlaying = false;
        });
        _controller!.pause();
        _controller!.seekTo(Duration.zero);
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
      _showControls = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }


  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || !_isInitialized) {
      return GestureDetector(
        onTap: () {
          widget.onTap?.call();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.coverImagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                );
              },
            ),
            if (!_hasError)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
        // 通知父组件点击事件
        widget.onTap?.call();
        if (_showControls) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _isPlaying) {
              setState(() {
                _showControls = false;
              });
            }
          });
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          if (_showControls) _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  VideoPlayerController? get controller => _controller;

}

