import 'dart:convert';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class BoatLastListingPrefs {
  static final EncryptedSharedPreferences _esp =
  EncryptedSharedPreferences();
  static const String _keyLastListing = 'boat_last_listing_v1';

  static Future<void> saveLastListing({
    required int yearBuilt,
    required double lengthMeters,
    required String powerType,
    required double price,
    required String address,
  }) async {
    final Map<String, dynamic> data = {
      'yearBuilt': yearBuilt,
      'lengthMeters': lengthMeters,
      'powerType': powerType,
      'price': price,
      'address': address,
    };
    final String jsonStr = jsonEncode(data);
    await _esp.setString(_keyLastListing, jsonStr);
  }

  static Future<Map<String, dynamic>?> loadLastListing() async {
    try {
      final String? jsonStr = await _esp.getString(_keyLastListing);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final Map<String, dynamic> data =
      jsonDecode(jsonStr) as Map<String, dynamic>;
      return data;
    } catch (_) {
      return null;
    }
  }
}
