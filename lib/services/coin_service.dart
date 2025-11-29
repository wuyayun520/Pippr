import 'package:shared_preferences/shared_preferences.dart';

class CoinService {
  static const String _coinsKey = 'pipprCoins';
  static const int _unlockCost = 56; // 解锁一个用户需要消耗的金币数

  /// 获取用户金币余额
  static Future<int> getCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Support both old and new keys for backward compatibility
      return prefs.getInt(_coinsKey) ?? 
             prefs.getInt('pipprCoins') ?? 
             prefs.getInt('pipprDiamonds') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// 扣除金币
  static Future<bool> deductCoins(int amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCoins = await getCoins();
      
      if (currentCoins < amount) {
        return false; // 金币不足
      }
      
      final newCoins = currentCoins - amount;
      await prefs.setInt(_coinsKey, newCoins);
      // Also update old key for backward compatibility
      await prefs.setInt('pipprCoins', newCoins);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 解锁用户需要消耗的金币数
  static int get unlockCost => _unlockCost;

  /// 检查是否有足够的金币解锁用户
  static Future<bool> hasEnoughCoinsForUnlock() async {
    final coins = await getCoins();
    return coins >= _unlockCost;
  }
}

