import 'package:flutter/material.dart';
import '../widgets/background_image_wrapper.dart';
import '../models/talent_model.dart';
import '../services/talent_service.dart';
import '../services/follow_service.dart';
import '../services/block_service.dart';
import '../theme/app_theme.dart';
import 'pippr_chat_screen.dart';
import 'fullscreen_video_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final TalentModel talent;

  const UserDetailScreen({super.key, required this.talent});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  List<TalentModel> _allTalents = [];
  bool _isFollowed = false;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _loadAllTalents();
    _loadFollowStatus();
    _loadBlockStatus();
  }

  Future<void> _loadBlockStatus() async {
    final isBlocked = await BlockService.isBlocked(widget.talent.id);
    setState(() {
      _isBlocked = isBlocked;
    });
  }

  Future<void> _loadFollowStatus() async {
    final isFollowed = await FollowService.isFollowed(widget.talent.id);
    setState(() {
      _isFollowed = isFollowed;
    });
  }

  Future<void> _toggleFollow() async {
    await FollowService.toggleFollow(widget.talent.id);
    setState(() {
      _isFollowed = !_isFollowed;
    });
  }

  Future<void> _loadAllTalents() async {
    final talents = await TalentService.loadTalents();
    setState(() {
      _allTalents = talents.take(6).toList(); // 取前6个用户作为推荐
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImageWrapper(
        child: SafeArea(
          bottom: false,
          child: _isBlocked
              ? _buildBlockedView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildUserInfo(),
                      const SizedBox(height: 24),
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: _buildChatButton(),
                      ),
                      _buildDescription(),
                      const SizedBox(height: 24),
                      _buildStats(),
                      const SizedBox(height: 24),
                      _buildFollowersList(),
                      const SizedBox(height: 24),
                      _buildPostsSection(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBlockedView() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'This user has been blocked',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You won\'t see their content anymore',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showMenu,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _isBlocked ? Icons.person_add : Icons.person_remove,
                  color: Colors.white,
                ),
                title: Text(
                  _isBlocked ? 'Unblock' : 'Block',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleBlock();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.report,
                  color: Colors.white,
                ),
                title: const Text(
                  'Report',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleReport();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBlock() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isBlocked ? 'Unblock User' : 'Block User'),
        content: Text(
          _isBlocked
              ? 'Are you sure you want to unblock this user?'
              : 'Are you sure you want to block this user? You won\'t see their content anymore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await BlockService.toggleBlock(widget.talent.id);
      setState(() {
        _isBlocked = !_isBlocked;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBlocked ? 'User has been blocked' : 'User has been unblocked'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleReport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Report User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(color: Colors.white24),
              _buildReportOption(
                icon: Icons.report,
                title: 'Spam',
                onTap: () => _submitReport('Spam'),
              ),
              _buildReportOption(
                icon: Icons.warning,
                title: 'Harassment or Bullying',
                onTap: () => _submitReport('Harassment or Bullying'),
              ),
              _buildReportOption(
                icon: Icons.block,
                title: 'Inappropriate Content',
                onTap: () => _submitReport('Inappropriate Content'),
              ),
              _buildReportOption(
                icon: Icons.person_off,
                title: 'Fake Account',
                onTap: () => _submitReport('Fake Account'),
              ),
              _buildReportOption(
                icon: Icons.flag,
                title: 'Other',
                onTap: () => _submitReport('Other'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white54,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _submitReport(String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Submitted'),
        content: Text('Thank you for reporting this user for "$reason". We will review it shortly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像 - 带渐变边框
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  Colors.purple.shade400,
                ],
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(
                widget.talent.avatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 60,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          // 用户名和Follow按钮
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.talent.name.split(' ').first, // 取名字的第一部分
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildFollowButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return GestureDetector(
      onTap: _toggleFollow,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          gradient: _isFollowed
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF46FB6D), Color(0xFF3CFFEF)],
                ),
          color: _isFollowed ? Colors.grey[300] : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _isFollowed ? 'Following' : 'Follow',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _isFollowed ? Colors.black87 : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const SizedBox(width: 140), // 与头像对齐
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PipprChatScreen(
                      userId: widget.talent.id,
                      userName: widget.talent.name,
                      userAvatar: widget.talent.avatar,
                    ),
                  ),
                );
              },
              child: Container(
         
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/pippr_user_chat.webp',
                      width: 120,
                      height: 38,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.chat_bubble_outline,
                          color: AppTheme.primaryColor,
                          size: 24,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (widget.talent.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.talent.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('${widget.talent.followers}', 'Followers'),
            _buildStatItem('${widget.talent.likes}', 'Likes'),
            _buildStatItem('${widget.talent.dynamics.length * 1}', 'Photoes'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowersList() {
    if (_allTalents.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _allTalents.length,
        itemBuilder: (context, index) {
          final talent = _allTalents[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipOval(
              child: Image.asset(
                talent.avatar,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Posts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildPostsGrid(),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    final dynamics = widget.talent.dynamics;

    if (dynamics.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No posts yet',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: dynamics.length,
      itemBuilder: (context, index) {
        final dynamic = dynamics[index];
        return _buildPostItem(dynamic);
      },
    );
  }

  Widget _buildPostItem(DynamicModel dynamic) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullscreenVideoScreen(
              videoPath: dynamic.video,
              videoCover: dynamic.videoCover,
              userName: widget.talent.name,
              userAvatar: widget.talent.avatar,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                dynamic.videoCover,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.image,
                      color: Colors.white54,
                      size: 48,
                    ),
                  );
                },
              ),
              // 播放按钮
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
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

