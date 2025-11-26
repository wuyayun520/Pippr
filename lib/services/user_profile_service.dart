import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserProfileService {
  static const String _userNameKey = 'user_name';
  static const String _userAvatarKey = 'user_avatar';
  static const String _defaultUserName = 'Peter';
  static const String _defaultAvatar = 'assets/AxisBandModel/pippr002/pippr002_avatar.webp';

  /// 获取用户名
  static Future<String> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey) ?? _defaultUserName;
    } catch (e) {
      return _defaultUserName;
    }
  }

  /// 保存用户名
  static Future<void> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
    } catch (e) {
      // Handle error
    }
  }

  /// 获取头像路径（沙盒路径或默认路径）
  static Future<String> getUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final avatarFileName = prefs.getString(_userAvatarKey);
      
      if (avatarFileName != null && avatarFileName.isNotEmpty) {
        // 获取沙盒路径
        final directory = await getApplicationDocumentsDirectory();
        final avatarPath = '${directory.path}/$avatarFileName';
        final file = File(avatarPath);
        
        // 检查文件是否存在
        if (await file.exists()) {
          return avatarPath;
        }
      }
      
      // 返回默认头像
      return _defaultAvatar;
    } catch (e) {
      return _defaultAvatar;
    }
  }

  /// 保存头像到沙盒并保存文件名
  static Future<String?> saveUserAvatar(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'user_avatar_$timestamp.jpg';
      final targetPath = '${directory.path}/$fileName';
      
      // 复制文件到沙盒
      final savedFile = await imageFile.copy(targetPath);
      
      // 保存文件名到 SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userAvatarKey, fileName);
      
      return savedFile.path;
    } catch (e) {
      return null;
    }
  }

  /// 获取头像文件名（用于显示）
  static Future<String> getAvatarFileName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userAvatarKey) ?? '';
    } catch (e) {
      return '';
    }
  }
}

