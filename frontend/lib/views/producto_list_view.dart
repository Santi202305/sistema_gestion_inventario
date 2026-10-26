import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/inventario_controller.dart';
import '../widgets/producto_list_item.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_widget.dart';
import '../widgets/app_drawer.dart';

class ProductoListView extends StatefulWidget {
  const ProductoListView({super.key});

  @override
  State<ProductoListView> createState() => _ProductoListViewState();
}

class _ProductoListViewState extends State<ProductoListView> {
  final _controller = InventarioController.instance;

  @override
  void initState() {
    super.initState();
    if (!_controller.hasLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.cargarProductos();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar lista',
            onPressed: () => _controller.cargarProductos(),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/productos'),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && !_controller.hasLoaded) {
            return const LoadingWidget(
              mensaje: 'Cargando catálogo de productos...',
            );
          }

          if (_controller.errorMessage != null && !_controller.hasLoaded) {
            return CustomErrorWidget(
              mensaje: _controller.errorMessage!,
              onRetry: () => _controller.cargarProductos(),
            );
          }

          final productos = _controller.productos;

          if (productos.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _controller.cargarProductos(silent: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  EmptyWidget(
                    titulo: 'Sin productos registrados',
                    mensaje: 'No hay productos en la base de datos. Comienza registrando el primero.',
                    botonTexto: 'Registrar Producto',
                    onBotonPressed: () => context.pushNamed('producto-nuevo'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _controller.cargarProductos(silent: true),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                return ProductoListItem(
                  producto: producto,
                  onTap: () {
                    if (producto.id != null) {
                      context.pushNamed(
                        'producto-detalle',
                        pathParameters: {'id': producto.id.toString()},
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('producto-nuevo'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo'),
      ),
    );
  }
}
