import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inventory_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gestión de Inventario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Electiva Profesional I',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.dashboard_rounded,
              color: currentRoute == '/'
                  ? const Color(0xFF1E3A8A)
                  : Colors.grey.shade600,
            ),
            title: const Text('Dashboard'),
            selected: currentRoute == '/',
            selectedTileColor: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute != '/') {
                context.goNamed('dashboard');
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.format_list_bulleted_rounded,
              color: currentRoute == '/productos'
                  ? const Color(0xFF1E3A8A)
                  : Colors.grey.shade600,
            ),
            title: const Text('Catálogo de Productos'),
            selected: currentRoute == '/productos',
            selectedTileColor: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute != '/productos') {
                context.goNamed('productos');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline_rounded),
            title: const Text('Registrar Producto'),
            onTap: () {
              Navigator.of(context).pop();
              context.pushNamed('producto-nuevo');
            },
          ),
          const Spacer(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Text(
                  'API REST + Flutter • v1.0.0',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
