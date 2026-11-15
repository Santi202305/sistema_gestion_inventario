import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'storage_service.dart';

/// Interceptor de Dio para:
/// 1. Inyectar automáticamente el encabezado "Authorization: Bearer `token`" en peticiones salientes.
/// 2. Capturar respuestas 401 Unauthorized para limpiar la sesión local y ejecutar el callback onUnauthorized.
class AuthInterceptor extends Interceptor {
  final StorageService storageService;
  final VoidCallback? onUnauthorized;

  AuthInterceptor({required this.storageService, this.onUnauthorized});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Si la petición ya incluye encabezado de autorización, respetarlo
    if (!options.headers.containsKey('Authorization')) {
      final token = await storageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Si el backend responde 401 Unauthorized (token ausente, inválido o expirado)
    if (err.response?.statusCode == 401) {
      // Limpiar sesión local almacenada
      await storageService.clearAuthData();

      // Notificar al controlador de sesión si existe callback
      if (onUnauthorized != null) {
        try {
          onUnauthorized!();
        } catch (e) {
          debugPrint('Error en callback onUnauthorized: $e');
        }
      }
    }

    return handler.next(err);
  }
}
