import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';

/// Servicio de almacenamiento local desacoplado:
/// - Almacenamiento seguro (flutter_secure_storage) para access_token
/// - Almacenamiento no sensible (shared_preferences) para datos de usuario
class StorageService {
  static const String _keyToken = 'jwt_access_token';
  static const String _keyUsuario = 'user_profile_data';

  final FlutterSecureStorage _secureStorage;
  final Future<SharedPreferences> _prefsFuture;

  StorageService({
    FlutterSecureStorage? secureStorage,
    Future<SharedPreferences>? prefsFuture,
  }) : _secureStorage =
           secureStorage ??
           const FlutterSecureStorage(
             aOptions: AndroidOptions(encryptedSharedPreferences: true),
             lOptions: LinuxOptions(),
           ),
       _prefsFuture = prefsFuture ?? SharedPreferences.getInstance();

  /// Guarda el access_token exclusivamente en almacenamiento seguro
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  /// Lee el access_token del almacenamiento seguro
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  /// Comprueba si existe un token guardado
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Devuelve una representación enmascarada del token para la UI de sesión
  /// (ej: "eyJhbGci...a1b2c3d4") sin exponer su contenido completo
  Future<String?> getMaskedToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;
    if (token.length <= 16) return '****';
    final start = token.substring(0, 10);
    final end = token.substring(token.length - 6);
    return '$start...$end';
  }

  /// Guarda los datos no sensibles del usuario en shared_preferences
  Future<void> saveUsuario(Usuario usuario) async {
    final prefs = await _prefsFuture;
    await prefs.setString(_keyUsuario, jsonEncode(usuario.toJson()));
  }

  /// Lee los datos no sensibles del usuario desde shared_preferences
  Future<Usuario?> getUsuario() async {
    final prefs = await _prefsFuture;
    final jsonStr = prefs.getString(_keyUsuario);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Usuario.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Borra todos los datos de sesión (token seguro y perfil local)
  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _keyToken);
    final prefs = await _prefsFuture;
    await prefs.remove(_keyUsuario);
  }
}
