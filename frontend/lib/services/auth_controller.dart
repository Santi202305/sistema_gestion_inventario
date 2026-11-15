import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
import 'api_exception.dart';
import 'auth_service.dart';

enum AuthStatus { initial, unauthenticated, authenticated }

class AuthController extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  Usuario? _usuario;
  bool _isLoading = false;
  String? _errorMessage;
  String? _sessionExpiredMessage;

  AuthController({AuthService? authService})
    : _authService = authService ?? AuthService();

  AuthService get authService => _authService;
  AuthStatus get status => _status;
  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get sessionExpiredMessage => _sessionExpiredMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Inicializa la verificación de sesión guardada al abrir la aplicación (persistencia)
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await _authService.isAuthenticated();
      if (hasToken) {
        _usuario = await _authService.getUsuarioActual();
        _status = AuthStatus.authenticated;
      } else {
        _usuario = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _usuario = null;
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inicia sesión con correo y contraseña
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _sessionExpiredMessage = null;
    notifyListeners();

    try {
      _usuario = await _authService.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado al iniciar sesión: $e';
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cierra sesión voluntariamente
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } finally {
      _usuario = null;
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      _errorMessage = null;
      _sessionExpiredMessage = null;
      notifyListeners();
    }
  }

  /// Maneja el evento de sesión expirada o token inválido detectado por AuthInterceptor
  void handleSessionExpired([
    String message = 'Tu sesión ha expirado o es inválida. Por favor, inicia sesión de nuevo.',
  ]) {
    _usuario = null;
    _status = AuthStatus.unauthenticated;
    _sessionExpiredMessage = message;
    notifyListeners();
  }

  /// Limpia los mensajes de error de la vista
  void clearMessages() {
    _errorMessage = null;
    _sessionExpiredMessage = null;
    notifyListeners();
  }
}
