import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/inventario_controller.dart';
import '../widgets/indicador_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/app_drawer.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _controller = InventarioController.instance;

  @override
  void initState() {
    super.initState();
    // Carga inicial solo si aún no se ha cargado
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
        title: const Text('Dashboard de Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () => _controller.cargarProductos(),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/'),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && !_controller.hasLoaded) {
            return const LoadingWidget(
              mensaje: 'Cargando indicadores de inventario...',
            );
          }

          if (_controller.errorMessage != null && !_controller.hasLoaded) {
            return CustomErrorWidget(
              mensaje: _controller.errorMessage!,
              onRetry: () => _controller.cargarProductos(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _controller.cargarProductos(silent: true),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // Identidad visual y bienvenida
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sistema de Inventario',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Resumen en tiempo real del almacén',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Indicador 1: Total de productos registrados
                IndicadorCard(
                  titulo: 'PRODUCTOS REGISTRADOS',
                  valor: '${_controller.totalProductos}',
                  subtitulo: 'Ítems únicos en catálogo',
                  icono: Icons.inventory_2_rounded,
                  colorPrimario: const Color(0xFF1E3A8A),
                  onTap: () => context.goNamed('productos'),
                ),

                // Indicador 2: Total de unidades disponibles
                IndicadorCard(
                  titulo: 'UNIDADES EN STOCK',
                  valor: '${_controller.totalUnidades}',
                  subtitulo: 'Existencias totales disponibles',
                  icono: Icons.inventory_rounded,
                  colorPrimario: const Color(0xFF0D9488),
                  onTap: () => context.goNamed('productos'),
                ),

                // Indicador 3: Valor económico total del inventario
                IndicadorCard(
                  titulo: 'VALOR TOTAL DEL INVENTARIO',
                  valor: _controller.valorTotalFormateado,
                  subtitulo: 'Calculado: ∑ (precio × cantidad)',
                  icono: Icons.account_balance_wallet_rounded,
                  colorPrimario: const Color(0xFFD97706),
                ),

                const SizedBox(height: 16),

                // Accesos directos a gestión de productos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.goNamed('productos'),
                          icon: const Icon(Icons.format_list_bulleted_rounded),
                          label: const Text('Ver Productos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.pushNamed('producto-nuevo'),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Nuevo Producto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
