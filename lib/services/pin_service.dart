import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinService {

  // Secure storage for PIN
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _pinKey = 'user_pin';
  static const String _pinSetKey = 'is_pin_set';

  Future<void> savePin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinSetKey, true);
  }

  // Check if PIN has been set
  Future<bool> isPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinSetKey) ?? false; // false if never set
  }

  // Verify entered PIN matches saved PIN
  Future<bool> verifyPin(String enteredPin) async {
    final savedPin = await _secureStorage.read(key: _pinKey);
    return savedPin == enteredPin; // true if matches
  }

  // for reset
  Future<void> deletePin() async {
    await _secureStorage.delete(key: _pinKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinSetKey, false);
  }

  // for verification only
  Future<String?> getPin() async {
    return await _secureStorage.read(key: _pinKey);
  }
}