import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class BoatLastEntryPrefs {
  static final EncryptedSharedPreferences _esp = EncryptedSharedPreferences();
  static const String _kLastBoatName = 'boat_last_boat_name_v1';

  static Future<void> saveLastBoatName(String name) async {
    await _esp.setString(_kLastBoatName, name);
  }

  static Future<String?> loadLastBoatName() async {
    try {
      final String? value = await _esp.getString(_kLastBoatName);
      if (value == null || value.isEmpty) return null;
      return value;
    } catch (_) {
      return null;
    }
  }
}
