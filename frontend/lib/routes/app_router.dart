import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/dashboard_view.dart';
import '../views/producto_list_view.dart';
import '../views/producto_detail_view.dart';
import '../views/producto_form_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardView(),
      ),
      GoRoute(
        path: '/productos',
        name: 'productos',
        builder: (context, state) => const ProductoListView(),
        routes: [
          // IMPORTANTE: /productos/nuevo se declara ANTES de /productos/:id para evitar conflictos
          GoRoute(
            path: 'nuevo',
            name: 'producto-nuevo',
            builder: (context, state) => const ProductoFormView(),
          ),
          GoRoute(
            path: ':id',
            name: 'producto-detalle',
            builder: (context, state) {
              final idStr = state.pathParameters['id'];
              final id = int.tryParse(idStr ?? '') ?? 0;
              return ProductoDetailView(productoId: id);
            },
            routes: [
              GoRoute(
                path: 'editar',
                name: 'producto-editar',
                builder: (context, state) {
                  final idStr = state.pathParameters['id'];
                  final id = int.tryParse(idStr ?? '') ?? 0;
                  return ProductoFormView(productoId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Ruta no encontrada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                '404 - Página no encontrada',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'No se encontró la ruta solicitada: ${state.uri}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.goNamed('dashboard'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Volver al Dashboard'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
