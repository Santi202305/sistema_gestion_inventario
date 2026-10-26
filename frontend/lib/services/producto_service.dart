import 'package:dio/dio.dart';

import '../config/env_config.dart';
import '../models/producto.dart';
import 'api_exception.dart';

class ProductoService {
  late final Dio _dio;

  ProductoService({Dio? customDio}) {
    if (customDio != null) {
      _dio = customDio;
    } else {
      _dio = Dio(
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
    }
  }

  /// Transforma cualquier DioException en una ApiException de la aplicación
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

  /// GET /api/productos -> Obtiene todos los productos registrados
  Future<List<Producto>> listar() async {
    try {
      final response = await _dio.get('/productos');
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => Producto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error al procesar la lista de productos: $e',
      );
    }
  }

  /// GET /api/productos/:id -> Obtiene un producto por su identificador
  Future<Producto> obtener(int id) async {
    try {
      final response = await _dio.get('/productos/$id');
      return Producto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error al consultar el producto: $e');
    }
  }

  /// POST /api/productos -> Registra un nuevo producto
  Future<Producto> crear(Producto producto) async {
    try {
      final response = await _dio.post(
        '/productos',
        data: producto.toJson(includeId: false),
      );
      return Producto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error al registrar el producto: $e');
    }
  }

  /// PUT /api/productos/:id -> Actualiza un producto existente
  Future<Producto> actualizar(int id, Producto producto) async {
    try {
      final response = await _dio.put(
        '/productos/$id',
        data: producto.toJson(includeId: false),
      );
      return Producto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error al actualizar el producto: $e');
    }
  }

  /// DELETE /api/productos/:id -> Elimina un producto por su identificador
  Future<void> eliminar(int id) async {
    try {
      await _dio.delete('/productos/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error al eliminar el producto: $e');
    }
  }
}
