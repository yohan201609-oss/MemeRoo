import 'package:shared_preferences/shared_preferences.dart';

class PreferencesCache {
  static final PreferencesCache _instance = PreferencesCache._internal();
  factory PreferencesCache() => _instance;
  PreferencesCache._internal();

  final Map<String, dynamic> _cache = {};
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setInt(String key, int value) async {
    _cache[key] = value;
    await _prefs?.setInt(key, value);
  }

  int? getInt(String key) {
    // Primero buscar en cache
    if (_cache.containsKey(key)) {
      return _cache[key] as int?;
    }
    // Si no está en cache, buscar en prefs
    final value = _prefs?.getInt(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  Future<void> setBool(String key, bool value) async {
    _cache[key] = value;
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) {
    if (_cache.containsKey(key)) {
      return _cache[key] as bool?;
    }
    final value = _prefs?.getBool(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  Future<void> setDouble(String key, double value) async {
    _cache[key] = value;
    await _prefs?.setDouble(key, value);
  }

  double? getDouble(String key) {
    if (_cache.containsKey(key)) {
      return _cache[key] as double?;
    }
    final value = _prefs?.getDouble(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  Future<void> setString(String key, String value) async {
    _cache[key] = value;
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    if (_cache.containsKey(key)) {
      return _cache[key] as String?;
    }
    final value = _prefs?.getString(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  Future<void> clear() async {
    _cache.clear();
    await _prefs?.clear();
  }

  Future<void> remove(String key) async {
    _cache.remove(key);
    await _prefs?.remove(key);
  }
}

