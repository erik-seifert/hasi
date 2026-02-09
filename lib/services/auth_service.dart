import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  String? _baseUrl;
  String? _token;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  String? get baseUrl => _baseUrl;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('ha_url');
    _token = await _storage.read(key: 'ha_token');

    if (_baseUrl != null && _token != null) {
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  Future<bool> login(String url, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Basic validation: Check if API responds
      // Clean URL: remove trailing slash
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }

      final uri = Uri.parse('$url/api/');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Success
        _baseUrl = url;
        _token = token;
        _isLoggedIn = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ha_url', url);
        await _storage.write(key: 'ha_token', value: token);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _baseUrl = null;
    _token = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ha_url');
    await _storage.delete(key: 'ha_token');

    notifyListeners();
  }
}
