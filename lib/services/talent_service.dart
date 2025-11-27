import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/talent_model.dart';

class TalentService {
  static Future<List<TalentModel>> loadTalents() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/AxisBandModel/talents_data.json');
      final dynamic jsonData = json.decode(jsonString);
      
      List<dynamic> talentsJson;
      if (jsonData is List) {
        talentsJson = jsonData;
      } else if (jsonData is Map<String, dynamic>) {
        talentsJson = jsonData['talents'] ?? [];
      } else {
        return [];
      }
      
      return talentsJson.map((e) => TalentModel.fromJson(e as Map<String, dynamic>)).toList();
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

