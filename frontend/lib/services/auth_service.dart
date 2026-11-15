import 'package:dio/dio.dart';

import '../config/env_config.dart';
import '../models/usuario.dart';
import 'api_exception.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio;
  final StorageService _storageService;

  AuthService({Dio? dio, StorageService? storageService})
    : _storageService = storageService ?? StorageService(),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: EnvConfig.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

  StorageService get storageService => _storageService;

  ApiException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Tiempo de espera agotado al conectar con el servidor',
        statusCode: 408,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'No se pudo conectar con el servidor. Verifique que el backend esté en ejecución.',
        statusCode: 503,
      );
    }

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      String message = 'Ocurrió un error inesperado';
      final fieldErrors = <String, List<String>>{};

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('message') &&
            responseData['message'] != null) {
          message = responseData['message'].toString();
        }

        if (responseData.containsKey('errors') &&
            responseData['errors'] is Map) {
          final errorsMap = responseData['errors'] as Map;
          errorsMap.forEach((key, val) {
            final fieldName = key.toString();
            if (val is List) {
              fieldErrors[fieldName] = val
                  .map((item) => item.toString())
                  .toList();
            } else if (val != null) {
              fieldErrors[fieldName] = [val.toString()];
            }
          });
        }
      }

      return ApiException(
        message: message,
        statusCode: statusCode,
        fieldErrors: fieldErrors,
      );
    }

    return ApiException(message: e.message ?? 'Error de conexión desconocido');
  }

  /// Inicia sesión con correo y contraseña.
  /// Guarda el access_token en almacenamiento seguro y los datos de usuario en SharedPreferences.
  Future<Usuario> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final token = data['token']?.toString();
        final usuarioMap = data['usuario'] as Map<String, dynamic>?;

        if (token == null || token.isEmpty || usuarioMap == null) {
          throw ApiException(
            message: 'Respuesta inválida del servidor: falta token o usuario',
          );
        }

        final usuario = Usuario.fromJson(usuarioMap);

        // Guardar token en almacenamiento seguro
        await _storageService.saveToken(token);

        // Guardar datos no sensibles en SharedPreferences
        await _storageService.saveUsuario(usuario);

        return usuario;
      }

      throw ApiException(
        message: 'Formato de respuesta desconocido al iniciar sesión',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error inesperado al iniciar sesión: $e');
    }
  }

  /// Cierra la sesión activa borrando los datos de autenticación locales
  Future<void> logout() async {
    await _storageService.clearAuthData();
  }

  /// Obtiene el usuario autenticado desde almacenamiento local
  Future<Usuario?> getUsuarioActual() async {
    return await _storageService.getUsuario();
  }

  /// Verifica si existe una sesión válida guardada
  Future<bool> isAuthenticated() async {
    return await _storageService.hasToken();
  }
}
