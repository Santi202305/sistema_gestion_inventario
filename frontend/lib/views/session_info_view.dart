import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_controller.dart';
import '../widgets/app_drawer.dart';

class SessionInfoView extends StatefulWidget {
  final AuthController authController;

  const SessionInfoView({super.key, required this.authController});

  @override
  State<SessionInfoView> createState() => _SessionInfoViewState();
}

class _SessionInfoViewState extends State<SessionInfoView> {
  String? _maskedToken;
  bool _isLoadingToken = true;

  @override
  void initState() {
    super.initState();
    _loadMaskedToken();
  }

  Future<void> _loadMaskedToken() async {
    setState(() => _isLoadingToken = true);
    final masked = await widget.authController.authService.storageService
        .getMaskedToken();
    if (mounted) {
      setState(() {
        _maskedToken = masked;
        _isLoadingToken = false;
      });
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Cerrar sesión'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar tu sesión actual? Se eliminarán los datos de autenticación del dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await widget.authController.logout();
      if (mounted) {
        context.goNamed('login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        final usuario = widget.authController.usuario;
        final isAuth = widget.authController.isAuthenticated;

        return Scaffold(
          appBar: AppBar(title: const Text('Información de Sesión')),
          drawer: const AppDrawer(currentRoute: '/sesion'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tarjeta Principal de Perfil
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFF1E3A8A)
                                  .withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 48,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              usuario?.nombre ?? 'Usuario no identificado',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              usuario?.email ?? 'Sin correo registrado',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Chip de estado
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isAuth
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isAuth
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isAuth
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    size: 16,
                                    color: isAuth
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isAuth ? 'Sesión activa' : 'Sin sesión',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isAuth
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Detalles Técnicos de la Sesión
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detalles de Seguridad',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const Divider(height: 20),
                            _buildDetailRow(
                              icon: Icons.vpn_key_rounded,
                              label: 'Estado del Token JWT',
                              valueWidget: _isLoadingToken
                                  ? const SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _maskedToken != null
                                          ? 'Presente y guardado en almacenamiento seguro'
                                          : 'No encontrado',
                                      style: TextStyle(
                                        color: _maskedToken != null
                                            ? const Color(0xFF059669)
                                            : Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              icon: Icons.fingerprint_rounded,
                              label: 'Token Enmascarado',
                              valueWidget: Text(
                                _maskedToken ?? 'N/A',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              icon: Icons.storage_rounded,
                              label: 'Almacenamiento de Token',
                              valueWidget: const Text(
                                'flutter_secure_storage (Keystore/Keyring seguro)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              icon: Icons.data_usage_rounded,
                              label: 'Almacenamiento de Perfil',
                              valueWidget: const Text(
                                'shared_preferences (Datos no sensibles)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón Cerrar Sesión
                    ElevatedButton.icon(
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required Widget valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              valueWidget,
            ],
          ),
        ),
      ],
    );
  }
}
