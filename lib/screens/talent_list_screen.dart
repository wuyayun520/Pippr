import 'package:flutter/material.dart';
import '../widgets/background_image_wrapper.dart';
import '../models/talent_model.dart';
import '../services/talent_service.dart';
import '../services/follow_service.dart';
import '../services/block_service.dart';
import '../services/coin_service.dart';
import '../services/unlock_service.dart';
import '../config/app_routes.dart';
import '../theme/app_theme.dart';
import 'user_detail_screen.dart';

class TalentListScreen extends StatefulWidget {
  const TalentListScreen({super.key});

  @override
  State<TalentListScreen> createState() => _TalentListScreenState();
}

class _TalentListScreenState extends State<TalentListScreen> {
  List<TalentModel> _allTalents = [];
  List<TalentModel> _filteredTalents = [];
  bool _isLoading = true;
  int _selectedCategory = 0;
  final Map<String, bool> _followedMap = {};

  // 分类图片
  final List<String> _categoryImages = [
    'assets/pippr_user_type1.webp',
    'assets/pippr_user_type2.webp',
    'assets/pippr_user_type3.webp',
  ];

  // 分类对应的用户索引范围
  final List<Map<String, int>> _categoryRanges = [
    {'startIndex': 0, 'endIndex': 6},   // 用户 1-6
    {'startIndex': 6, 'endIndex': 14},  // 用户 7-14
    {'startIndex': 14, 'endIndex': 19}, // 用户 15-19
  ];

  @override
  void initState() {
    super.initState();
    _loadTalents();
  }

  Future<void> _loadTalents() async {
    final talents = await TalentService.loadTalents();
    final blockedList = await BlockService.getBlockedList();
    
    // 过滤被拉黑的用户
    final unblockedTalents = talents.where((t) => !blockedList.contains(t.id)).toList();
    
    // 加载所有用户的关注状态
    for (final talent in unblockedTalents) {
      final isFollowed = await FollowService.isFollowed(talent.id);
      _followedMap[talent.id] = isFollowed;
    }
    
    setState(() {
      _allTalents = unblockedTalents;
      _filterTalents();
      _isLoading = false;
    });
  }

  void _filterTalents() {
    final range = _categoryRanges[_selectedCategory];
    final startIndex = range['startIndex']!;
    final endIndex = range['endIndex']!;

    setState(() {
      _filteredTalents = _allTalents
          .skip(startIndex)
          .take(endIndex - startIndex)
          .toList();
    });
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategory = index;
    });
    _filterTalents();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topImageHeight = screenWidth * 320 / 375; // 根据设计稿比例

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImageWrapper(
        child: Column(
          children: [
            // 顶部区域：背景图 + 分类选择器（从状态栏开始）
            _buildTopSection(topImageHeight),
            // 用户列表
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : _buildTalentList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(double height) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // 背景图片 - 从顶部状态栏开始
          Positioned.fill(
            child: Image.asset(
              'assets/pippr_dynamic_nor.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black54);
              },
            ),
          ),
          // 返回按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          // 分类选择器图片 - 根据选择显示不同图片
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 130,
              child: Stack(
                children: [
                  // 当前选中的分类图片
                  Positioned.fill(
                    child: Image.asset(
                      _categoryImages[_selectedCategory],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                        );
                      },
                    ),
                  ),
                // 三个点击区域
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onCategorySelected(0),
                          behavior: HitTestBehavior.opaque,
                          child: Container(),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onCategorySelected(1),
                          behavior: HitTestBehavior.opaque,
                          child: Container(),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onCategorySelected(2),
                          behavior: HitTestBehavior.opaque,
                          child: Container(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTalentList() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
      itemCount: _filteredTalents.length,
      itemBuilder: (context, index) {
        final talent = _filteredTalents[index];
        return _buildTalentCard(talent);
      },
    );
  }

  Widget _buildTalentCard(TalentModel talent) {
    return GestureDetector(
      onTap: () => _handleTalentCardTap(talent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 背景图片 - 铺满整个卡片
              Image.asset(
                talent.background,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                  );
                },
              ),
              // 底部信息 - 叠加在图片上
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: _buildCardInfo(talent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardInfo(TalentModel talent) {
    // 将 talentType 拆分成多个标签
    final tags = _getTalentTags(talent.talentType);

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), // 白色背景，透明度0.6
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  talent.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: tags.map((tag) => _buildTag(tag)).toList(),
                ),
              ],
            ),
          ),
          _buildFollowButton(talent),
        ],
      ),
    );
  }

  Future<void> _toggleFollow(TalentModel talent) async {
    await FollowService.toggleFollow(talent.id);
    setState(() {
      _followedMap[talent.id] = !(_followedMap[talent.id] ?? false);
    });
  }

  Future<void> _handleTalentCardTap(TalentModel talent) async {
    // 检查用户是否已解锁
    final isUnlocked = await UnlockService.isUnlocked(talent.id);
    
    if (isUnlocked) {
      // 已解锁，直接跳转
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(talent: talent),
          ),
        );
      }
      return;
    }

    // 未解锁，检查金币余额
    final coins = await CoinService.getCoins();
    final unlockCost = CoinService.unlockCost;
    final hasEnoughCoins = coins >= unlockCost;

    if (!hasEnoughCoins) {
      // 金币不足，提示用户并跳转到钱包页面
      final shouldRecharge = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900]!.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Insufficient Coins',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'You need $unlockCost coins to unlock this user. Your current balance is $coins coins.\n\nWould you like to recharge?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Recharge',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
      );

      if (shouldRecharge == true && mounted) {
        Navigator.of(context).pushNamed(AppRoutes.wallet);
      }
      return;
    }

    // 金币足够，确认是否解锁
    final shouldUnlock = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900]!.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Unlock User',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Unlocking this user will cost $unlockCost coins.\n\nYour current balance: $coins coins\nAfter unlock: ${coins - unlockCost} coins\n\nDo you want to continue?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Unlock',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );

    if (shouldUnlock == true) {
      // 扣除金币并解锁用户
      final success = await CoinService.deductCoins(unlockCost);
      
      if (success) {
        await UnlockService.unlockUser(talent.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User unlocked! -$unlockCost coins'),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          
          // 跳转到详情页面
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserDetailScreen(talent: talent),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to unlock user. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          );
        }
      }
    }
  }

  List<String> _getTalentTags(String talentType) {
    // 根据不同的 talentType 生成标签
    final Map<String, List<String>> tagMap = {
      'Dancing': ['Model', 'Rap'],
      'Piano': ['Singer', 'Actor'],
      'Guitar': ['Musician', 'Composer'],
      'Drums': ['Performer', 'Artist'],
      'Violin': ['Classical', 'Soloist'],
      'Singing': ['Vocalist', 'Pop'],
      'Acting': ['Actor', 'Drama'],
      'Comedy': ['Comedy', 'Entertainment'],
      'Magic': ['Magician', 'Illusionist'],
      'Photography': ['Photographer', 'Artist'],
    };

    return tagMap[talentType] ?? [talentType];
  }

  Widget _buildTag(String tag) {
    // 根据标签生成不同的颜色
    final colors = {
      'Model': const Color(0xFF4FFFB0),
      'Rap': const Color(0xFFE8E8E8),
      'Singer': const Color(0xFF4FFFB0),
      'Actor': const Color(0xFFD4B8FF),
      'Musician': const Color(0xFF87CEEB),
      'Composer': const Color(0xFFFFE4B5),
      'Performer': const Color(0xFFFFB6C1),
      'Artist': const Color(0xFFDDA0DD),
      'Classical': const Color(0xFFF0E68C),
      'Soloist': const Color(0xFF98FB98),
      'Vocalist': const Color(0xFFADD8E6),
      'Pop': const Color(0xFFFFDAB9),
      'Drama': const Color(0xFFE6E6FA),
      'Comedy': const Color(0xFFFFFACD),
      'Entertainment': const Color(0xFFB0E0E6),
      'Magician': const Color(0xFFDDA0DD),
      'Illusionist': const Color(0xFFE0FFFF),
      'Photographer': const Color(0xFFFAFAD2),
    };

    final bgColor = colors[tag] ?? const Color(0xFFE8E8E8);
    final textColor = _getContrastColor(bgColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Color _getContrastColor(Color bgColor) {
    // 根据背景颜色亮度选择文字颜色
    final luminance = bgColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  Widget _buildFollowButton(TalentModel talent) {
    final isFollowed = _followedMap[talent.id] ?? false;
    
    return GestureDetector(
      onTap: () => _toggleFollow(talent),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isFollowed
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF46FB6D), Color(0xFF3CFFEF)],
                ),
          color: isFollowed ? Colors.grey[300] : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isFollowed ? 'Following' : 'Follow',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

