import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../config/app_routes.dart';
import '../widgets/background_image_wrapper.dart';
import '../services/user_profile_service.dart';

class TabThreeScreen extends StatefulWidget {
  const TabThreeScreen({super.key});

  @override
  State<TabThreeScreen> createState() => _TabThreeScreenState();
}

class _TabThreeScreenState extends State<TabThreeScreen> {
  String _userName = 'Peter';
  String _userAvatar = 'assets/AxisBandModel/pippr002/pippr002_avatar.webp';
  final int _followers = 0;
  final int _likes = 0;
  final int _photos = 0;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final name = await UserProfileService.getUserName();
    final avatar = await UserProfileService.getUserAvatar();
    setState(() {
      _userName = name;
      _userAvatar = avatar;
    });
  }

  Future<void> _showEditDialog() async {
    final TextEditingController nameController = TextEditingController(text: _userName);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头像选择
            GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      const Color(0xFF9C7CF4),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: ClipOval(
                  child: _userAvatar.startsWith('/') || _userAvatar.startsWith('file://')
                      ? Image.file(
                          File(_userAvatar),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white54,
                                size: 50,
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          _userAvatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white54,
                                size: 50,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tap avatar to change',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 20),
            // 名称输入
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                await UserProfileService.saveUserName(newName);
                await _loadUserProfile();
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: Text(
              'Save',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (picked != null) {
        final imageFile = File(picked.path);
        final savedPath = await UserProfileService.saveUserAvatar(imageFile);
        
        if (savedPath != null) {
          setState(() {
            _userAvatar = savedPath;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Avatar updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save avatar'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImageWrapper(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(),
                const SizedBox(height: 30),
                _buildStatsSection(),
                const SizedBox(height: 30),
                _buildMenuItems(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 头像
          GestureDetector(
            onTap: _pickAvatar,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    const Color(0xFF9C7CF4),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: ClipOval(
                child: _userAvatar.startsWith('/') || _userAvatar.startsWith('file://')
                    ? Image.file(
                        File(_userAvatar),
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
                      )
                    : Image.asset(
                        _userAvatar,
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
          ),
          const SizedBox(width: 20),
          // 用户名和编辑按钮
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildEditButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: _showEditDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF6B5CE7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_outlined,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('$_followers', 'Followers'),
          _buildDivider(),
          _buildStatItem('$_likes', 'Likes'),
          _buildDivider(),
          _buildStatItem('$_photos', 'Photoes'),
        ],
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
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildMenuItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.check_box_outlined,
            iconColor: const Color(0xFF5DADE2),
            title: 'User Contract',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.termsOfService);
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.error_outline,
            iconColor: const Color(0xFFFFB74D),
            title: 'Privacy Policy',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.privacyPolicy);
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.info_outline,
            iconColor: const Color(0xFF5DADE2),
            title: 'About us',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.aboutUs);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
