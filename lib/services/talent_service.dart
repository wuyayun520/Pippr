import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/talent_model.dart';

class TalentService {
  static Future<List<TalentModel>> loadTalents() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/AxisBandModel/talents_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> talentsJson = jsonData['talents'] ?? [];
      return talentsJson.map((e) => TalentModel.fromJson(e)).toList();
    } catch (e) {
      print('Error loading talents: $e');
      return [];
    }
  }

  static Future<List<TalentModel>> getTopArtists({int count = 5}) async {
    final talents = await loadTalents();
    return talents.take(count).toList();
  }
}

