import 'package:flutter/foundation.dart';

import '../models/producto.dart';
import 'producto_service.dart';
import 'api_exception.dart';

class InventarioController extends ChangeNotifier {
  static final InventarioController instance = InventarioController._internal();

  final ProductoService _service;

  InventarioController._internal({ProductoService? service})
    : _service = service ?? ProductoService();

  List<Producto> _productos = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoaded = false;

  List<Producto> get productos => List.unmodifiable(_productos);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoaded => _hasLoaded;

  // Indicadores calculados del inventario
  int get totalProductos => _productos.length;
  int get totalUnidades => _productos.fold(0, (sum, p) => sum + p.cantidad);
  double get valorTotalInventario =>
      _productos.fold(0.0, (sum, p) => sum + p.valorTotal);
  String get valorTotalFormateado =>
      Producto.formatearMoneda(valorTotalInventario);

  /// Carga la lista completa de productos desde el backend
  Future<void> cargarProductos({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _productos = await _service.listar();
      _errorMessage = null;
      _hasLoaded = true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Error inesperado al cargar inventario: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene un producto por su ID directamente del backend
  Future<Producto> obtenerProducto(int id) async {
    return await _service.obtener(id);
  }

  /// Crea un nuevo producto y refresca la lista de inventario
  Future<Producto> crearProducto(Producto producto) async {
    final nuevo = await _service.crear(producto);
    await cargarProductos(silent: true);
    return nuevo;
  }

  /// Actualiza un producto existente y refresca la lista de inventario
  Future<Producto> actualizarProducto(int id, Producto producto) async {
    final actualizado = await _service.actualizar(id, producto);
    await cargarProductos(silent: true);
    return actualizado;
  }

  /// Elimina un producto y refresca la lista de inventario
  Future<void> eliminarProducto(int id) async {
    await _service.eliminar(id);
    await cargarProductos(silent: true);
  }
}
