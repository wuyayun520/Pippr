import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../widgets/background_image_wrapper.dart';

class PipprChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userAvatar;

  const PipprChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  });

  @override
  State<PipprChatScreen> createState() => _PipprChatScreenState();
}

class _PipprChatScreenState extends State<PipprChatScreen> {
  List<_PipprChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _voiceRecorder = AudioRecorder();
  bool _isRecording = false;
  DateTime? _recordingStartTime;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<String> _getMediaDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/pippr_chat_media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir.path;
  }

  Future<void> _loadMessages() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pippr_chat_history_${widget.userId}.json');
    if (await file.exists()) {
      try {
        final jsonStr = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonStr);
        
        setState(() {
          _messages = jsonList.map((e) => _PipprChatMessage.fromJson(e)).toList();
        });
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      } catch (e) {
        debugPrint('Error loading messages: $e');
      }
    }
  }

  Future<void> _saveMessages() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/pippr_chat_history_${widget.userId}.json');
      
      final jsonStr = json.encode(_messages.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonStr);
      debugPrint('Saved ${_messages.length} messages for user ${widget.userId}');
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_PipprChatMessage(
        text: text,
        isMe: true,
        time: _getTimeStamp(),
        type: _PipprChatMessageType.text,
      ));
    });
    _textController.clear();
    _scrollToBottom();
    _saveMessages();
  }

  Future<void> _sendImage(File imageFile) async {
    try {
      final mediaDir = await _getMediaDirectory();
      final fileName = 'pippr_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await imageFile.copy('$mediaDir/$fileName');
      
      setState(() {
        _messages.add(_PipprChatMessage(
          imagePath: fileName,
          isMe: true,
          time: _getTimeStamp(),
          type: _PipprChatMessageType.image,
        ));
      });
      _scrollToBottom();
      _saveMessages();
    } catch (e) {
      _showErrorSnackBar('Failed to send image: $e');
    }
  }

  Future<void> _sendVoice(String audioPath, Duration duration) async {
    try {
      final mediaDir = await _getMediaDirectory();
      final fileName = 'pippr_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await File(audioPath).copy('$mediaDir/$fileName');
      
      setState(() {
        _messages.add(_PipprChatMessage(
          audioPath: fileName,
          audioDuration: duration,
          isMe: true,
          time: _getTimeStamp(),
          type: _PipprChatMessageType.audio,
        ));
      });
      _scrollToBottom();
      _saveMessages();
        
      _showSuccessSnackBar('Voice message sent! 🎵');
    } catch (e) {
      _showErrorSnackBar('Failed to send voice message: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 85
      );
      if (picked != null) {
        await _sendImage(File(picked.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _toggleVoiceRecording() async {
    try {
      if (_isRecording) {
        // 停止录制
        final path = await _voiceRecorder.stop();
        setState(() {
          _isRecording = false;
          _recordingStartTime = null;
        });
          
        if (path != null) {
          final duration = await _getAudioDuration(path);
          if (duration.inSeconds > 0) {
            await _sendVoice(path, duration);
          } else {
            _showErrorSnackBar('Recording too short');
          }
        }
      } else {
        // 检查权限
        if (await _voiceRecorder.hasPermission()) {
          final dir = await getTemporaryDirectory();
          final filePath = '${dir.path}/pippr_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
            
          await _voiceRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.aacLc,
              bitRate: 128000,
              sampleRate: 44100,
            ),
            path: filePath,
          );
            
          setState(() {
            _isRecording = true;
            _recordingStartTime = DateTime.now();
          });
            
          _showInfoSnackBar('Recording... 🎙️ Tap again to stop');
        } else {
          _showErrorSnackBar('Microphone permission denied');
        }
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
      });
      _showErrorSnackBar('Recording error: $e');
    }
  }

  Future<Duration> _getAudioDuration(String path) async {
    final player = AudioPlayer();
    try {
      await player.setFilePath(path);
      return player.duration ?? Duration.zero;
    } catch (e) {
      debugPrint('Error getting audio duration: $e');
      return Duration.zero;
    } finally {
      await player.dispose();
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getTimeStamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _textController.dispose();
    _chatScrollController.dispose();
    _voiceRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.7),
              ],
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(widget.userAvatar),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
      body: BackgroundImageWrapper(
        child: Column(
          children: [
            // 聊天头部装饰条
            Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // 消息列表
            Expanded(
              child: Container(
                color: Colors.transparent,
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _chatScrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _PipprChatBubble(
                          message: msg,
                          onImageTap: (file) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  backgroundColor: Colors.black,
                                  body: Stack(
                                    children: [
                                      Center(
                                        child: InteractiveViewer(
                                          minScale: 0.5,
                                          maxScale: 3.0,
                                          child: Image.file(
                                            file,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 50,
                                        right: 20,
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
          // 输入栏
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: _PipprChatInputBar(
              controller: _textController,
              onSend: _sendMessage,
              onImage: _pickImage,
              onRecord: _toggleVoiceRecording,
              isRecording: _isRecording,
              recordingStartTime: _recordingStartTime,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.15),
                  AppTheme.primaryColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 70,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Send a message, photo, or voice note',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

enum _PipprChatMessageType { text, image, audio }

class _PipprChatMessage {
  final String? text;
  final String? imagePath;
  final String? audioPath;
  final Duration? audioDuration;
  final bool isMe;
  final String time;
  final _PipprChatMessageType type;

  _PipprChatMessage({
    this.text,
    this.imagePath,
    this.audioPath,
    this.audioDuration,
    required this.isMe,
    required this.time,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'imagePath': imagePath,
    'audioPath': audioPath,
    'audioDuration': audioDuration?.inMilliseconds,
    'isMe': isMe,
    'time': time,
    'type': type.name,
  };

  static _PipprChatMessage fromJson(Map<String, dynamic> json) => _PipprChatMessage(
    text: json['text'],
    imagePath: json['imagePath'],
    audioPath: json['audioPath'],
    audioDuration: json['audioDuration'] != null 
        ? Duration(milliseconds: json['audioDuration']) 
        : null,
    isMe: json['isMe'] ?? true,
    time: json['time'] ?? '',
    type: _PipprChatMessageType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => _PipprChatMessageType.text,
    ),
  );
}

class _PipprChatBubble extends StatefulWidget {
  final _PipprChatMessage message;
  final void Function(File file)? onImageTap;
  const _PipprChatBubble({required this.message, this.onImageTap});

  @override
  State<_PipprChatBubble> createState() => _PipprChatBubbleState();
}

class _PipprChatBubbleState extends State<_PipprChatBubble> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == _PipprChatMessageType.audio) {
      _duration = widget.message.audioDuration ?? Duration.zero;
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    try {
      final msg = widget.message;
      final dir = await getApplicationDocumentsDirectory();
      final absPath = '${dir.path}/pippr_chat_media/${msg.audioPath}';
      
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer();
        
        // 监听播放状态
        _audioPlayer!.playerStateStream.listen((state) {
          if (mounted) {
            setState(() {
              _isPlaying = state.playing;
            });
          }
        });
        
        // 监听播放进度
        _audioPlayer!.positionStream.listen((pos) {
          if (mounted) {
            setState(() {
              _position = pos;
            });
          }
        });
        
        // 监听播放完成
        _audioPlayer!.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (mounted) {
              setState(() {
                _position = Duration.zero;
                _isPlaying = false;
              });
            }
          }
        });
      }
      
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        await _audioPlayer!.setFilePath(absPath);
        await _audioPlayer!.play();
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    
    if (msg.type == _PipprChatMessageType.audio && msg.audioPath != null) {
      final current = _position > _duration ? _duration : _position;
      return Align(
        alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          padding: const EdgeInsets.all(18),
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 300),
          decoration: BoxDecoration(
            gradient: msg.isMe 
                ? LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: msg.isMe ? null : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: msg.isMe ? const Radius.circular(20) : const Radius.circular(4),
              bottomRight: msg.isMe ? const Radius.circular(4) : const Radius.circular(20),
            ),
            border: msg.isMe ? null : Border.all(color: const Color(0xFF3A3A3A), width: 1),
            boxShadow: [
              BoxShadow(
                color: msg.isMe 
                    ? AppTheme.primaryColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: msg.isMe 
                            ? Colors.white.withOpacity(0.25)
                            : AppTheme.primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: msg.isMe 
                              ? Colors.white.withOpacity(0.3)
                              : AppTheme.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: msg.isMe 
                                ? Colors.white.withOpacity(0.2)
                                : AppTheme.primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: msg.isMe ? Colors.white : AppTheme.primaryColor,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: (msg.isMe ? Colors.white : AppTheme.primaryColor).withOpacity(0.2),
                          ),
                          child: LinearProgressIndicator(
                            value: _duration.inMilliseconds == 0 
                                ? 0 
                                : current.inMilliseconds / _duration.inMilliseconds,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              msg.isMe ? Colors.white : AppTheme.primaryColor
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(current),
                              style: TextStyle(
                                color: msg.isMe ? Colors.white : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: TextStyle(
                                color: msg.isMe ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  msg.time,
                  style: TextStyle(
                    color: msg.isMe ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (msg.type == _PipprChatMessageType.image && msg.imagePath != null) {
      return Align(
        alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTap: () async {
            final dir = await getApplicationDocumentsDirectory();
            final absPath = '${dir.path}/pippr_chat_media/${msg.imagePath}';
            widget.onImageTap?.call(File(absPath));
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FutureBuilder<Directory>(
                    future: getApplicationDocumentsDirectory(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox(width: 160, height: 160);
                      final absPath = '${snapshot.data!.path}/pippr_chat_media/${msg.imagePath}';
                      return Image.file(
                        File(absPath),
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 160,
                            height: 160,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 40),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    msg.time,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // 文本消息
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: msg.isMe 
              ? LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: msg.isMe ? null : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: msg.isMe ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: msg.isMe ? const Radius.circular(4) : const Radius.circular(20),
          ),
          border: msg.isMe ? null : Border.all(color: const Color(0xFF3A3A3A), width: 1),
          boxShadow: [
            BoxShadow(
              color: msg.isMe 
                  ? AppTheme.primaryColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text ?? '',
              style: TextStyle(
                color: msg.isMe ? Colors.white : Colors.white,
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                msg.time,
                style: TextStyle(
                  color: msg.isMe ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _PipprChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onImage;
  final VoidCallback onRecord;
  final bool isRecording;
  final DateTime? recordingStartTime;
  
  const _PipprChatInputBar({
    required this.controller, 
    required this.onSend, 
    required this.onImage, 
    required this.onRecord, 
    required this.isRecording, 
    this.recordingStartTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Column(
          children: [
            if (isRecording && recordingStartTime != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFE53E3E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 录音动画指示器
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 录音图标
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 录音文字
                    const Text(
                      'Recording...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    // 录音时长
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          final elapsed = DateTime.now().difference(recordingStartTime!);
                          return Text(
                            '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'monospace',
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF3A3A3A), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 录音按钮
                  Container(
                    decoration: BoxDecoration(
                      gradient: isRecording 
                          ? const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFE53E3E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      shape: BoxShape.circle,
                      border: isRecording 
                          ? Border.all(color: Colors.white.withOpacity(0.3), width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: (isRecording ? const Color(0xFFFF6B6B) : AppTheme.primaryColor).withOpacity(0.6),
                          blurRadius: isRecording ? 20 : 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: isRecording ? 24 : 22,
                      ),
                      onPressed: onRecord,
                      tooltip: isRecording ? 'Stop recording' : 'Record voice',
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // 图片按钮
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                      onPressed: onImage,
                      tooltip: 'Send image',
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // 输入框
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF3A3A3A),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => onSend(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // 发送按钮
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: onSend,
                      tooltip: 'Send message',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}