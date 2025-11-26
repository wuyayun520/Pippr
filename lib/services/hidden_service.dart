import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HiddenService {
  static const String _hiddenKey = 'hidden_dynamics';

  static Future<List<String>> getHiddenDynamics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hiddenJson = prefs.getString(_hiddenKey);
      if (hiddenJson != null) {
        final List<dynamic> hiddenList = json.decode(hiddenJson);
        return hiddenList.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> hideDynamic(String dynamicId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hiddenList = await getHiddenDynamics();
      if (!hiddenList.contains(dynamicId)) {
        hiddenList.add(dynamicId);
        await prefs.setString(_hiddenKey, json.encode(hiddenList));
      }
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> unhideDynamic(String dynamicId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hiddenList = await getHiddenDynamics();
      hiddenList.remove(dynamicId);
      await prefs.setString(_hiddenKey, json.encode(hiddenList));
    } catch (e) {
      // Handle error
    }
  }

  static Future<bool> isHidden(String dynamicId) async {
    try {
      final hiddenList = await getHiddenDynamics();
      return hiddenList.contains(dynamicId);
    } catch (e) {
      return false;
    }
  }
}

