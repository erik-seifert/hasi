import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  String? _baseUrl;
  String? _token;
  String? _refreshToken;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  String? get baseUrl => _baseUrl;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('ha_url');
    _token = await _storage.read(key: 'ha_token');
    _refreshToken = await _storage.read(key: 'ha_refresh_token');

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
        // Clear old refresh token if manual token is used
        await _storage.delete(key: 'ha_refresh_token');
        _refreshToken = null;

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

  Future<bool> loginWithCredentials(
    String url,
    String username,
    String password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }

      final response = await http.post(
        Uri.parse('$url/auth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'client_id': 'http://hasi.app',
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token']; // Might be null

        if (accessToken != null) {
          _baseUrl = url;
          _token = accessToken;
          _refreshToken = refreshToken;
          _isLoggedIn = true;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('ha_url', url);
          await _storage.write(key: 'ha_token', value: accessToken);
          if (refreshToken != null) {
            await _storage.write(key: 'ha_refresh_token', value: refreshToken);
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Invalid response from server';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error =
            'Login failed: ${response.statusCode}. Make sure "Trusted Networks" or password auth is enabled.';
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
    _refreshToken = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ha_url');
    await _storage.delete(key: 'ha_token');
    await _storage.delete(key: 'ha_refresh_token');

    notifyListeners();
  }
}
