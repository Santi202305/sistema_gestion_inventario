import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/producto.dart';
import '../services/inventario_controller.dart';
import '../services/api_exception.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class ProductoFormView extends StatefulWidget {
  final int? productoId;

  const ProductoFormView({super.key, this.productoId});

  bool get esEdicion => productoId != null;

  @override
  State<ProductoFormView> createState() => _ProductoFormViewState();
}

class _ProductoFormViewState extends State<ProductoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = InventarioController.instance;

  final _nombreCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();

  bool _isLoadingInitial = false;
  bool _isSubmitting = false;
  String? _initialError;

  // Errores 422 provenientes del backend mapeados por campo
  Map<String, List<String>> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    if (widget.esEdicion) {
      _cargarDatosParaEditar();
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _cantidadCtrl.dispose();
    _categoriaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosParaEditar() async {
    setState(() {
      _isLoadingInitial = true;
      _initialError = null;
    });

    try {
      final p = await _controller.obtenerProducto(widget.productoId!);
      _nombreCtrl.text = p.nombre;
      _codigoCtrl.text = p.codigo;
      _descripcionCtrl.text = p.descripcion ?? '';
      _precioCtrl.text = p.precio.toString();
      _cantidadCtrl.text = p.cantidad.toString();
      _categoriaCtrl.text = p.categoria;

      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _initialError = e.message;
          _isLoadingInitial = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialError = 'Error al cargar datos del producto: $e';
          _isLoadingInitial = false;
        });
      }
    }
  }

  Future<void> _guardar() async {
    // Limpiar errores previos de servidor antes de validar
    setState(() {
      _fieldErrors = {};
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final nuevoProducto = Producto(
      id: widget.productoId,
      nombre: _nombreCtrl.text.trim(),
      codigo: _codigoCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim().isEmpty
          ? null
          : _descripcionCtrl.text.trim(),
      precio: double.tryParse(_precioCtrl.text.trim()) ?? 0.0,
      cantidad: int.tryParse(_cantidadCtrl.text.trim()) ?? 0,
      categoria: _categoriaCtrl.text.trim(),
    );

    try {
      if (widget.esEdicion) {
        await _controller.actualizarProducto(widget.productoId!, nuevoProducto);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Producto "${nuevoProducto.nombre}" actualizado con éxito',
              ),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        await _controller.crearProducto(nuevoProducto);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Producto "${nuevoProducto.nombre}" registrado con éxito',
              ),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          context.goNamed('productos');
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _fieldErrors = e.fieldErrors;
        });

        // Re-disparar validación local para mostrar mensajes del backend bajo cada campo
        _formKey.currentState?.validate();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  String? _getErrorForField(String field) {
    if (_fieldErrors.containsKey(field) && _fieldErrors[field]!.isNotEmpty) {
      return _fieldErrors[field]!.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.esEdicion ? 'Editar Producto' : 'Nuevo Producto';

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoadingInitial) {
      return const LoadingWidget(mensaje: 'Cargando datos para edición...');
    }

    if (_initialError != null) {
      return CustomErrorWidget(
        mensaje: _initialError!,
        onRetry: _cargarDatosParaEditar,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Código del producto
            TextFormField(
              controller: _codigoCtrl,
              decoration: InputDecoration(
                labelText: 'Código único *',
                hintText: 'Ej. TEC-004',
                prefixIcon: const Icon(Icons.qr_code_rounded),
                errorText: _getErrorForField('codigo'),
              ),
              textCapitalization: TextCapitalization.characters,
              enabled: !_isSubmitting,
              onChanged: (_) {
                if (_fieldErrors.containsKey('codigo')) {
                  setState(() => _fieldErrors.remove('codigo'));
                }
              },
              validator: (val) {
                final serverErr = _getErrorForField('codigo');
                if (serverErr != null) return serverErr;
                if (val == null || val.trim().isEmpty) {
                  return 'El código es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nombre del producto
            TextFormField(
              controller: _nombreCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre del producto *',
                hintText: 'Ej. Disco Duro Externo 1TB',
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
                errorText: _getErrorForField('nombre'),
              ),
              enabled: !_isSubmitting,
              onChanged: (_) {
                if (_fieldErrors.containsKey('nombre')) {
                  setState(() => _fieldErrors.remove('nombre'));
                }
              },
              validator: (val) {
                final serverErr = _getErrorForField('nombre');
                if (serverErr != null) return serverErr;
                if (val == null || val.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Categoría
            TextFormField(
              controller: _categoriaCtrl,
              decoration: InputDecoration(
                labelText: 'Categoría *',
                hintText: 'Ej. Tecnología, Papelería, Abarrotes',
                prefixIcon: const Icon(Icons.category_outlined),
                errorText: _getErrorForField('categoria'),
              ),
              enabled: !_isSubmitting,
              onChanged: (_) {
                if (_fieldErrors.containsKey('categoria')) {
                  setState(() => _fieldErrors.remove('categoria'));
                }
              },
              validator: (val) {
                final serverErr = _getErrorForField('categoria');
                if (serverErr != null) return serverErr;
                if (val == null || val.trim().isEmpty) {
                  return 'La categoría es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Fila de Precio y Cantidad
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Precio
                Expanded(
                  child: TextFormField(
                    controller: _precioCtrl,
                    decoration: InputDecoration(
                      labelText: 'Precio (COP) *',
                      hintText: 'Ej. 45000',
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      errorText: _getErrorForField('precio'),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    enabled: !_isSubmitting,
                    onChanged: (_) {
                      if (_fieldErrors.containsKey('precio')) {
                        setState(() => _fieldErrors.remove('precio'));
                      }
                    },
                    validator: (val) {
                      final serverErr = _getErrorForField('precio');
                      if (serverErr != null) return serverErr;
                      if (val == null || val.trim().isEmpty) {
                        return 'El precio es obligatorio';
                      }
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null) {
                        return 'Número no válido';
                      }
                      if (parsed <= 0) {
                        return 'Debe ser > 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Cantidad
                Expanded(
                  child: TextFormField(
                    controller: _cantidadCtrl,
                    decoration: InputDecoration(
                      labelText: 'Cantidad *',
                      hintText: 'Ej. 10',
                      prefixIcon: const Icon(
                        Icons.format_list_numbered_rounded,
                      ),
                      errorText: _getErrorForField('cantidad'),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isSubmitting,
                    onChanged: (_) {
                      if (_fieldErrors.containsKey('cantidad')) {
                        setState(() => _fieldErrors.remove('cantidad'));
                      }
                    },
                    validator: (val) {
                      final serverErr = _getErrorForField('cantidad');
                      if (serverErr != null) return serverErr;
                      if (val == null || val.trim().isEmpty) {
                        return 'La cantidad es obligatoria';
                      }
                      final parsed = int.tryParse(val.trim());
                      if (parsed == null) {
                        return 'Entero requerido';
                      }
                      if (parsed < 0) {
                        return 'Debe ser >= 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Descripción (opcional)
            TextFormField(
              controller: _descripcionCtrl,
              decoration: InputDecoration(
                labelText: 'Descripción adicional (opcional)',
                hintText:
                    'Características, especificaciones o detalles del producto',
                prefixIcon: const Icon(Icons.description_outlined),
                alignLabelWithHint: true,
                errorText: _getErrorForField('descripcion'),
              ),
              maxLines: 3,
              enabled: !_isSubmitting,
              onChanged: (_) {
                if (_fieldErrors.containsKey('descripcion')) {
                  setState(() => _fieldErrors.remove('descripcion'));
                }
              },
            ),
            const SizedBox(height: 28),

            // Botón de guardar
            ElevatedButton(
              onPressed: _isSubmitting ? null : _guardar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: _isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Guardando producto...'),
                      ],
                    )
                  : Text(
                      widget.esEdicion
                          ? 'Actualizar Producto'
                          : 'Registrar Producto',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
