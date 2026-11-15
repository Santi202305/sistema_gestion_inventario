import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'routes/app_router.dart';
import 'services/auth_controller.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga de variables de entorno desde el archivo .env
  await dotenv.load(fileName: ".env");

  // Instanciar controlador de autenticación e inicializar verificación de sesión
  final authController = AuthController();
  await authController.checkAuthStatus();

  runApp(InventarioApp(authController: authController));
}

class InventarioApp extends StatefulWidget {
  final AuthController authController;

  const InventarioApp({super.key, required this.authController});

  @override
  State<InventarioApp> createState() => _InventarioAppState();
}

class _InventarioAppState extends State<InventarioApp> {
  late final _router = AppRouter.createRouter(widget.authController);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema de Gestión de Inventario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
