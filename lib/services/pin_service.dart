import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinService {

  // ── Secure storage for PIN ──
  // flutter_secure_storage encrypts data on device
  // Much safer than SharedPreferences for sensitive data
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ── Keys for storage ──
  static const String _pinKey = 'user_pin';
  static const String _pinSetKey = 'is_pin_set';

  // ── Save PIN to secure storage ──
  Future<void> savePin(String pin) async {
    // Save encrypted PIN
    await _secureStorage.write(key: _pinKey, value: pin);

    // Save flag that PIN has been set
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinSetKey, true);
  }

  // ── Check if PIN has been set ──
  Future<bool> isPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinSetKey) ?? false; // false if never set
  }

  // ── Verify entered PIN matches saved PIN ──
  Future<bool> verifyPin(String enteredPin) async {
    final savedPin = await _secureStorage.read(key: _pinKey);
    return savedPin == enteredPin; // true if matches
  }

  // ── Delete PIN (for reset) ──
  Future<void> deletePin() async {
    await _secureStorage.delete(key: _pinKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinSetKey, false);
  }

  // ── Get saved PIN (for verification only) ──
  Future<String?> getPin() async {
    return await _secureStorage.read(key: _pinKey);
  }
}