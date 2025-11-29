import 'package:shared_preferences/shared_preferences.dart';

class UnlockService {
  static const String _unlockedUsersKey = 'pippr_unlocked_users';

  /// 检查用户是否已解锁
  static Future<bool> isUnlocked(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unlockedList = prefs.getStringList(_unlockedUsersKey) ?? [];
      return unlockedList.contains(userId);
    } catch (e) {
      return false;
    }
  }

  /// 解锁用户
  static Future<void> unlockUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unlockedList = prefs.getStringList(_unlockedUsersKey) ?? [];
      if (!unlockedList.contains(userId)) {
        unlockedList.add(userId);
        await prefs.setStringList(_unlockedUsersKey, unlockedList);
      }
    } catch (e) {
      // Handle error
    }
  }

  /// 获取所有已解锁的用户ID列表
  static Future<List<String>> getUnlockedUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_unlockedUsersKey) ?? [];
    } catch (e) {
      return [];
    }
  }
}

