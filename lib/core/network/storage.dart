import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'user_token_info';

  Future<void> saveTokenInfo(Map<String, dynamic> tokenInfo) async {
    await _storage.write(key: _tokenKey, value: json.encode(tokenInfo));
  }

  Future<Map<String, dynamic>?> getTokenInfo() async {
    final tokenInfoString = await _storage.read(key: _tokenKey);
    if (tokenInfoString != null) {
      return json.decode(tokenInfoString);
    }
    return null;
  }

  Future<void> deleteTokenInfo() async {
    await _storage.delete(key: _tokenKey);
  }
}
