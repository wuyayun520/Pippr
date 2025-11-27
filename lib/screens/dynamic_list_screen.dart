import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/talent_model.dart';
import '../services/talent_service.dart';
import '../services/like_service.dart';
import '../services/hidden_service.dart';
import '../services/block_service.dart';
import '../theme/app_theme.dart';
import '../widgets/video_player_widget.dart';
import 'pippr_chat_screen.dart';

class DynamicListScreen extends StatefulWidget {
  const DynamicListScreen({super.key});

  @override
  State<DynamicListScreen> createState() => _DynamicListScreenState();
}

class _DynamicListScreenState extends State<DynamicListScreen> {
  List<TalentModel> _talents = [];
  bool _isLoading = true;
  PageController _pageController = PageController();
  int _currentPageIndex = 0;
  VideoPlayerController? _currentVideoController;
  final Map<String, bool> _likedMap = {};
  final Map<int, VideoPlayerController> _controllerMap = {}; // 存储每个索引对应的控制器
  Key _pageViewKey = UniqueKey(); // 用于强制刷新 PageView
  bool _showUI = true; // 控制 UI 显示/隐藏

  @override
  void initState() {
    super.initState();
    _loadTalents();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // 注意：不需要手动 dispose 控制器，VideoPlayerWidget 会自己管理
    _controllerMap.clear();
    _currentVideoController = null;
    super.dispose();
  }

  Future<void> _loadTalents() async {
    final talents = await TalentService.loadTalents();
    final hiddenDynamics = await HiddenService.getHiddenDynamics();
    final blockedList = await BlockService.getBlockedList();
    
    final filteredTalents = talents.where((t) {
      // 过滤被拉黑的用户
      if (blockedList.contains(t.id)) return false;
      // 过滤没有动态的用户
      if (t.dynamics.isEmpty) return false;
      // 过滤被隐藏的动态
      return !hiddenDynamics.contains(t.dynamics.first.id);
    }).toList();
    
    for (final talent in filteredTalents) {
      for (final dynamic in talent.dynamics) {
        final isLiked = await LikeService.isLiked(dynamic.id);
        _likedMap[dynamic.id] = isLiked;
      }
    }
    
    setState(() {
      _talents = filteredTalents;
      _isLoading = false;
    });
  }

  Future<void> _handleNotInterested(int index) async {
    if (index >= _talents.length) return;
    
    final talent = _talents[index];
    final dynamic = talent.dynamics.first;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Interested'),
        content: const Text('Are you sure you want to hide this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HiddenService.hideDynamic(dynamic.id);
      
      // 计算新索引：如果删除的不是最后一个，保持当前索引；否则往前一个
      final newIndex = index < _talents.length - 1 ? index : index - 1;
      
      // 先移除元素
      _talents.removeAt(index);
      
      // 如果列表空了，返回上一页
      if (_talents.isEmpty) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }
      
      // 清空视频控制器
      _currentVideoController = null;
      
      // 计算有效索引
      final validIndex = newIndex >= 0 && newIndex < _talents.length 
          ? newIndex 
          : (_talents.isNotEmpty ? 0 : -1);
      
      if (validIndex >= 0) {
        // 重新创建 PageController 并定位到正确索引
        _pageController.dispose();
        _pageController = PageController(initialPage: validIndex);
        _currentPageIndex = validIndex;
        
        // 更新 key 强制 PageView 完全重建
        setState(() {
          _pageViewKey = UniqueKey();
        });
      }
    }
  }

  Future<void> _toggleLike(String dynamicId) async {
    await LikeService.toggleLike(dynamicId);
    setState(() {
      _likedMap[dynamicId] = !(_likedMap[dynamicId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Stack(
              children: [
                PageView.builder(
                  key: _pageViewKey, // 添加 key 用于强制刷新
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _talents.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                    // 从 map 中获取当前页面的控制器
                    final controller = _controllerMap[index];
                    if (controller != null && controller.value.isInitialized) {
                      setState(() {
                        _currentVideoController = controller;
                      });
                    } else {
                      // 如果控制器还没有准备好，清空当前控制器
                      setState(() {
                        _currentVideoController = null;
                      });
                    }
                  },
                  itemBuilder: (context, index) {
                    final talent = _talents[index];
                    return _buildDynamicItem(
                      talent,
                      index == _currentPageIndex,
                      index,
                    );
                  },
                ),
                // 顶部导航栏 - 根据 _showUI 显示/隐藏
                if (_showUI)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildTopBar(),
                  ),
              ],
            ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Discover',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _handleNotInterested(_currentPageIndex);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 28,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicItem(
    TalentModel talent,
    bool isCurrentPage,
    int index,
  ) {
    final dynamic = talent.dynamics.first;
    final isLiked = _likedMap[dynamic.id] ?? false;

    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPlayerWidget(
          videoPath: dynamic.video,
          autoPlay: isCurrentPage,
          onControllerReady: (controller) {
            if (mounted && controller != null) {
              // 存储控制器到 map
              _controllerMap[index] = controller;
              // 如果是当前页面，立即更新
              if (index == _currentPageIndex) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && index == _currentPageIndex && controller.value.isInitialized) {
                    setState(() {
                      _currentVideoController = controller;
                    });
                  }
                });
              }
            }
          },
          onTap: () {
            setState(() {
              _showUI = !_showUI;
            });
          },
        ),
        // 进度条 - 根据 _showUI 显示/隐藏
        if (_showUI && isCurrentPage && 
            _currentVideoController != null && 
            _currentVideoController!.value.isInitialized)
          Positioned(
            bottom: 160, // 调整位置，确保在底部卡片上方
            left: 0,
            right: 0,
            child: _buildProgressBar(_currentVideoController!),
          ),
        // 底部卡片 - 根据 _showUI 显示/隐藏
        if (_showUI)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomCard(talent, dynamic, isLiked),
          ),
      ],
    );
  }

  Widget _buildProgressBar(VideoPlayerController controller) {
    if (!controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized) {
          return const SizedBox.shrink();
        }

        final duration = value.duration;
        final position = value.position;
        final progress = duration.inMilliseconds > 0
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                ),
                child: Slider(
                  value: progress,
                  onChanged: (newValue) {
                    if (value.isInitialized) {
                      final newPosition = Duration(
                        milliseconds: (newValue * duration.inMilliseconds).toInt(),
                      );
                      controller.seekTo(newPosition);
                    }
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildBottomCard(TalentModel talent, DynamicModel dynamic, bool isLiked) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 动态内容文本
          if (dynamic.content.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                dynamic.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          // 用户信息和按钮
          Row(
            children: [
              _buildAvatarWithAdd(talent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      talent.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            talent.talentType,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                       
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _toggleLike(dynamic.id);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        isLiked
                            ? 'assets/pippr_activity_like_nor.webp'
                            : 'assets/pippr_activity_like_pre.webp',
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: Colors.black54,
                            size: 22,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PipprChatScreen(
                            userId: talent.id,
                            userName: talent.name,
                            userAvatar: talent.avatar,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/pippr_activity_edit.webp',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithAdd(TalentModel talent) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          talent.avatar,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.person,
                color: Colors.grey,
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }
}

