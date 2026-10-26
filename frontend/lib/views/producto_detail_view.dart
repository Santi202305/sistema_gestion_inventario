import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/producto.dart';
import '../services/inventario_controller.dart';
import '../services/api_exception.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/confirm_dialog.dart';

class ProductoDetailView extends StatefulWidget {
  final int productoId;

  const ProductoDetailView({super.key, required this.productoId});

  @override
  State<ProductoDetailView> createState() => _ProductoDetailViewState();
}

class _ProductoDetailViewState extends State<ProductoDetailView> {
  final _controller = InventarioController.instance;

  Producto? _producto;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final p = await _controller.obtenerProducto(widget.productoId);
      if (mounted) {
        setState(() {
          _producto = p;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error inesperado al cargar el producto: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmarYEliminar() async {
    final confirmado = await ConfirmDialog.mostrar(
      context,
      titulo: '¿Eliminar producto?',
      mensaje:
          '¿Está seguro de que desea eliminar "${_producto?.nombre}"? Esta acción no se puede deshacer.',
      textoConfirmar: 'Eliminar',
    );

    if (confirmado == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        await _controller.eliminarProducto(widget.productoId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Producto "${_producto?.nombre}" eliminado correctamente',
              ),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          context.goNamed('productos');
        }
      } on ApiException catch (e) {
        if (mounted) {
          setState(() => _isDeleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isDeleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        actions: [
          if (_producto != null && !_isDeleting) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Editar',
              onPressed: () async {
                final resultado = await context.pushNamed(
                  'producto-editar',
                  pathParameters: {'id': widget.productoId.toString()},
                );
                // Si se editó con éxito, recargar detalle
                if (resultado == true && mounted) {
                  _cargarDetalle();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Eliminar',
              color: Colors.red.shade200,
              onPressed: _confirmarYEliminar,
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(mensaje: 'Consultando datos del producto...');
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(
        mensaje: _errorMessage!,
        onRetry: _cargarDetalle,
      );
    }

    final p = _producto!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta principal con nombre, código y categoría
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.codigo,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.categoria,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    p.nombre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Identificador ID: #${p.id}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Métricas numéricas: Precio, Cantidad, Subtotal
          Row(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRECIO UNITARIO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.precioFormateado,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STOCK DISPONIBLE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${p.cantidad} unidades',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: p.cantidad > 0
                                ? const Color(0xFF1E3A8A)
                                : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Valor total del producto en inventario
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: Color(0xFFD97706),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VALOR TOTAL EN INVENTARIO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.valorTotalFormateado,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Descripción
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.descripcion != null && p.descripcion!.isNotEmpty
                        ? p.descripcion!
                        : 'Sin descripción adicional disponible.',
                    style: TextStyle(
                      fontSize: 14,
                      color: p.descripcion != null && p.descripcion!.isNotEmpty
                          ? const Color(0xFF334155)
                          : Colors.grey.shade500,
                      height: 1.4,
                      fontStyle:
                          p.descripcion != null && p.descripcion!.isNotEmpty
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Botones de acción principales
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final resultado = await context.pushNamed(
                      'producto-editar',
                      pathParameters: {'id': widget.productoId.toString()},
                    );
                    if (resultado == true && mounted) {
                      _cargarDetalle();
                    }
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Editar Producto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isDeleting ? null : _confirmarYEliminar,
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
