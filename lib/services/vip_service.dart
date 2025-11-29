import 'package:shared_preferences/shared_preferences.dart';

class VipService {
  static const String _vipStatusKey = 'pipprIsVip';
  static const String _vipExpiryKey = 'pipprVipExpiry';

  /// 检查用户是否是 VIP（包括检查是否过期）
  static Future<bool> isVip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isVip = prefs.getBool(_vipStatusKey) ?? false;
      
      if (!isVip) {
        return false;
      }
      
      // 检查是否过期
      final expiryStr = prefs.getString(_vipExpiryKey);
      if (expiryStr == null) {
        return false;
      }
      
      final expiry = DateTime.tryParse(expiryStr);
      if (expiry == null) {
        return false;
      }
      
      // 如果过期时间已过，返回 false
      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }

  /// 获取 VIP 过期时间
  static Future<DateTime?> getVipExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryStr = prefs.getString(_vipExpiryKey);
      if (expiryStr == null) {
        return null;
      }
      return DateTime.tryParse(expiryStr);
    } catch (e) {
      return null;
    }
  }

  /// 检查用户是否是月订阅 VIP
  static Future<bool> isMonthlyVip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isVip = prefs.getBool(_vipStatusKey) ?? false;
      
      if (!isVip) {
        return false;
      }
      
      // 检查 VIP 类型
      final vipType = prefs.getString('pipprVipType') ?? '';
      if (vipType != 'monthly') {
        return false;
      }
      
      // 检查是否过期
      final expiryStr = prefs.getString(_vipExpiryKey);
      if (expiryStr == null) {
        return false;
      }
      
      final expiry = DateTime.tryParse(expiryStr);
      if (expiry == null) {
        return false;
      }
      
      // 如果过期时间已过，返回 false
      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }
}

