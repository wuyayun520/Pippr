import 'package:flutter/material.dart';
import '../widgets/background_image_wrapper.dart';
import '../models/talent_model.dart';
import '../services/talent_service.dart';
import '../services/block_service.dart';
import '../services/coin_service.dart';
import '../services/unlock_service.dart';
import '../services/vip_service.dart';
import '../config/app_routes.dart';
import '../theme/app_theme.dart';
import 'user_detail_screen.dart';

class TabOneScreen extends StatefulWidget {
  const TabOneScreen({super.key});

  @override
  State<TabOneScreen> createState() => _TabOneScreenState();
}

class _TabOneScreenState extends State<TabOneScreen> {
  List<TalentModel> _topArtists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopArtists();
  }

  Future<void> _loadTopArtists() async {
    final artists = await TalentService.getTopArtists(count: 5);
    final blockedList = await BlockService.getBlockedList();
    
    // 过滤被拉黑的用户
    final unblockedArtists = artists.where((a) => !blockedList.contains(a.id)).toList();
    
    setState(() {
      _topArtists = unblockedArtists;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImageWrapper(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildTopArtistsSection(),
                const SizedBox(height: 32),
                _buildCardsSection(),
                const SizedBox(height: 32),
                _buildTalentAgentSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopArtistsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 181,
            height: 31,
            child: Image.asset(
              'assets/pippr_topartists.webp',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  'Top artists',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _topArtists.length,
                    itemBuilder: (context, index) {
                      final artist = _topArtists[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildArtistAvatar(artist),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildArtistAvatar(TalentModel artist) {
    return GestureDetector(
      onTap: () => _handleArtistCardTap(artist),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7B68EE),
              Color(0xFF4169E1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B68EE).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Image.asset(
            artist.avatar,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.person,
                  color: Colors.white54,
                  size: 32,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleArtistCardTap(TalentModel artist) async {
    // 检查用户是否已解锁
    final isUnlocked = await UnlockService.isUnlocked(artist.id);
    
    if (isUnlocked) {
      // 已解锁，直接跳转
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(talent: artist),
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
        await UnlockService.unlockUser(artist.id);
        
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
              builder: (context) => UserDetailScreen(talent: artist),
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

  Future<void> _handleDynamicCardTap() async {
    // 每次获取用户最新 VIP 状态
    final isVip = await VipService.isVip();
    
    if (isVip) {
      // 是 VIP，直接跳转
      if (mounted) {
        Navigator.of(context).pushNamed('/dynamic-list');
      }
      return;
    }

    // 不是 VIP，提示用户并跳转到 VIP 订阅页面
    final shouldSubscribe = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900]!.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'VIP Required',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This feature is only available for VIP members.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VIP Plans:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Weekly: \$12.99/week',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'Monthly: \$49.99/month',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Would you like to subscribe to VIP?',
              style: TextStyle(color: Colors.white70),
            ),
          ],
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
              'Subscribe',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );

    if (shouldSubscribe == true && mounted) {
      Navigator.of(context).pushNamed(AppRoutes.vip);
    }
  }

  Widget _buildCardsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildDynamicCard()),
          const SizedBox(width: 16),
          Expanded(child: _buildTalentCard()),
        ],
      ),
    );
  }

  Widget _buildDynamicCard() {
    return GestureDetector(
      onTap: () => _handleDynamicCardTap(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/pippr_home_post.webp',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.grey[800],
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTalentCard() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/talent-list');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/pippr_home_talent.webp',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.grey[800],
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTalentAgentSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 281 / 375;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          // Navigate to Talent Agent page
        },
        child: Container(
          width: double.infinity,
          height: imageHeight,
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(24),
          //   color: Colors.white.withOpacity(0.1),
          // ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/pippr_home_Group.webp',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple.withOpacity(0.3),
                              Colors.blue.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 60,
                                color: Colors.white70,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Talent Agent',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
