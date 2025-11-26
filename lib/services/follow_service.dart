import 'package:shared_preferences/shared_preferences.dart';

class FollowService {
  static const String _followedKeyPrefix = 'followed_';

  /// 检查是否已关注
  static Future<bool> isFollowed(String talentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_followedKeyPrefix$talentId') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 切换关注状态
  static Future<void> toggleFollow(String talentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentStatus = await isFollowed(talentId);
      await prefs.setBool('$_followedKeyPrefix$talentId', !currentStatus);
    } catch (e) {
      // Handle error
    }
  }

  /// 设置关注状态
  static Future<void> setFollowed(String talentId, bool followed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_followedKeyPrefix$talentId', followed);
    } catch (e) {
      // Handle error
    }
  }

  /// 获取所有已关注的用户ID列表
  static Future<List<String>> getFollowedList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      return keys
          .where((key) => key.startsWith(_followedKeyPrefix))
          .where((key) => prefs.getBool(key) == true)
          .map((key) => key.replaceFirst(_followedKeyPrefix, ''))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

