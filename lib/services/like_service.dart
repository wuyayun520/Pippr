import 'package:shared_preferences/shared_preferences.dart';

class LikeService {
  static const String _likedKeyPrefix = 'liked_';

  static Future<bool> isLiked(String dynamicId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_likedKeyPrefix$dynamicId') ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> toggleLike(String dynamicId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentStatus = await isLiked(dynamicId);
      await prefs.setBool('$_likedKeyPrefix$dynamicId', !currentStatus);
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> setLiked(String dynamicId, bool liked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_likedKeyPrefix$dynamicId', liked);
    } catch (e) {
      // Handle error
    }
  }
}

