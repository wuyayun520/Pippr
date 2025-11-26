import 'package:shared_preferences/shared_preferences.dart';

class BlockService {
  static const String _blockedKeyPrefix = 'blocked_';

  /// 检查是否被拉黑
  static Future<bool> isBlocked(String talentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_blockedKeyPrefix$talentId') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 切换拉黑状态
  static Future<void> toggleBlock(String talentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentStatus = await isBlocked(talentId);
      await prefs.setBool('$_blockedKeyPrefix$talentId', !currentStatus);
    } catch (e) {
      // Handle error
    }
  }

  /// 设置拉黑状态
  static Future<void> setBlocked(String talentId, bool blocked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_blockedKeyPrefix$talentId', blocked);
    } catch (e) {
      // Handle error
    }
  }

  /// 获取所有被拉黑的用户ID列表
  static Future<List<String>> getBlockedList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      return keys
          .where((key) => key.startsWith(_blockedKeyPrefix))
          .where((key) => prefs.getBool(key) == true)
          .map((key) => key.replaceFirst(_blockedKeyPrefix, ''))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

