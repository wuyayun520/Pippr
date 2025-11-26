import 'package:flutter/material.dart';
import 'dart:math';
import '../models/talent_model.dart';
import '../services/talent_service.dart';
import '../services/block_service.dart';
import 'user_detail_screen.dart';

class TabTwoScreen extends StatefulWidget {
  const TabTwoScreen({super.key});

  @override
  State<TabTwoScreen> createState() => _TabTwoScreenState();
}

class _TabTwoScreenState extends State<TabTwoScreen>
    with TickerProviderStateMixin {
  List<TalentModel> _allTalents = [];
  List<_MatchedUser> _matchedUsers = [];
  bool _isScanning = true;
  bool _showUsers = false;

  late AnimationController _radarController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadTalentsAndMatch();
  }

  void _initAnimations() {
    // 雷达扫描动画
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // 脉冲动画
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadTalentsAndMatch() async {
    final talents = await TalentService.loadTalents();
    final blockedList = await BlockService.getBlockedList();

    // 过滤被拉黑的用户
    _allTalents =
        talents.where((t) => !blockedList.contains(t.id)).toList();

    // 3秒后显示匹配结果
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      _generateMatchedUsers();
      setState(() {
        _isScanning = false;
        _showUsers = true;
      });
    }
  }

  void _generateMatchedUsers() {
    final random = Random();
    final shuffled = List<TalentModel>.from(_allTalents)..shuffle(random);
    final count = min(3 + random.nextInt(2), shuffled.length); // 随机显示3-4个用户

    // 定义用户卡片的位置 (边距, top偏移, 是否右对齐)
    final positions = [
      const _CardPosition(18, -120, true),    // 右上
      const _CardPosition(8, 0, false),       // 左中
      const _CardPosition(8, 100, true),      // 右中
      const _CardPosition(8, 200, false),     // 左下
    ];

    _matchedUsers = [];
    for (int i = 0; i < count; i++) {
      _matchedUsers.add(_MatchedUser(
        talent: shuffled[i],
        position: positions[i],
        delay: i * 200, // 依次出现的延迟
      ));
    }
  }

  void _refresh() {
    setState(() {
      _isScanning = true;
      _showUsers = false;
      _matchedUsers = [];
    });

    // 重新扫描
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _generateMatchedUsers();
        setState(() {
          _isScanning = false;
          _showUsers = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9), // 浅绿黄色
              Color(0xFFB2EBF2), // 浅青色
              Color(0xFFE1BEE7), // 浅紫色
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 雷达圆环
                    _buildRadarCircles(),
                    // 中心表情
                    _buildCenterEmoji(),
                    // 匹配到的用户卡片
                    if (_showUsers) ..._buildUserCards(),
                  ],
                ),
              ),
              _buildRefreshButton(),
              const SizedBox(height: 140), // 给底部TabBar留空间
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB74D),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Discover Talents',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _isScanning
                ? 'Finding amazing talents for you...'
                : 'The following talents have been matched for you~',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCircles() {
    return AnimatedBuilder(
      animation: _radarController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 静态圆环
            ...List.generate(3, (index) {
              final size = 150.0 + (index * 100);
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5 - index * 0.1),
                    width: 1.5,
                  ),
                ),
              );
            }),
            // 扫描动画效果
            if (_isScanning)
              ...List.generate(2, (index) {
                return AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) {
                    final delay = index * 0.5;
                    final progress =
                        (_radarController.value + delay) % 1.0;
                    final size = 100.0 + (progress * 250);
                    final opacity = (1.0 - progress) * 0.6;

                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF64B5F6).withOpacity(opacity),
                          width: 2,
                        ),
                      ),
                    );
                  },
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildCenterEmoji() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF81D4FA),
                  const Color(0xFF29B6F6).withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF29B6F6).withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 表情图标
                  const Text(
                    '🤩',
                    style: TextStyle(fontSize: 50),
                  ),
                  // 麦克风装饰
                  Positioned(
                    right: -8,
                    bottom: 0,
                    child: Transform.rotate(
                      angle: -0.3,
                      child: const Text(
                        '🎤',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  // 星星装饰
                  Positioned(
                    right: -10,
                    top: 5,
                    child: Transform.rotate(
                      angle: 0.3,
                      child: const Text(
                        '✨',
                        style: TextStyle(fontSize: 16),
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
  }

  List<Widget> _buildUserCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    final centerY = MediaQuery.of(context).size.height / 2 - 240;
    
    return _matchedUsers.map((user) {
      return _TalentCard(
        matchedUser: user,
        screenWidth: screenWidth,
        centerY: centerY,
        delay: Duration(milliseconds: user.delay),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserDetailScreen(talent: user.talent),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildRefreshButton() {
    return GestureDetector(
      onTap: _isScanning ? null : _refresh,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
        decoration: BoxDecoration(
          color: _isScanning
              ? Colors.grey[400]
              : const Color(0xFFFFB74D),
          borderRadius: BorderRadius.circular(30),
          boxShadow: _isScanning
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFFFFB74D).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Text(
          _isScanning ? 'Matching...' : 'Refresh',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// 卡片位置数据
class _CardPosition {
  final double leftMargin;  // 左边距
  final double topOffset;   // 相对于中心的垂直偏移
  final bool alignRight;    // 是否右对齐

  const _CardPosition(this.leftMargin, this.topOffset, this.alignRight);
}

// 匹配的用户数据模型
class _MatchedUser {
  final TalentModel talent;
  final _CardPosition position;
  final int delay;

  _MatchedUser({
    required this.talent,
    required this.position,
    required this.delay,
  });
}

// 用户才艺卡片组件
class _TalentCard extends StatefulWidget {
  final _MatchedUser matchedUser;
  final double screenWidth;
  final double centerY;
  final Duration delay;
  final VoidCallback onTap;

  const _TalentCard({
    required this.matchedUser,
    required this.screenWidth,
    required this.centerY,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_TalentCard> createState() => _TalentCardState();
}

class _TalentCardState extends State<_TalentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // 延迟显示
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _isVisible = true);
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final position = widget.matchedUser.position;
    final topPos = widget.centerY + position.topOffset;

    return Positioned(
      left: position.alignRight ? null : position.leftMargin,
      right: position.alignRight ? position.leftMargin : null,
      top: topPos,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: widget.screenWidth * 0.45,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 用户头像
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFB74D),
                        Color(0xFFFF8A65),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.matchedUser.talent.avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 用户信息
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.matchedUser.talent.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF76FFE4).withOpacity(0.3),
                              const Color(0xFF46FB6D).withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.matchedUser.talent.talentType,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF00897B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
