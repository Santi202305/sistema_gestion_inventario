import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final IconData icono;
  final String? botonTexto;
  final VoidCallback? onBotonPressed;

  const EmptyWidget({
    super.key,
    this.titulo = 'Sin registros disponibles',
    this.mensaje = 'No se encontraron productos registrados en el inventario.',
    this.icono = Icons.inventory_2_outlined,
    this.botonTexto,
    this.onBotonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 56, color: const Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (botonTexto != null && onBotonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onBotonPressed,
                icon: const Icon(Icons.add_rounded),
                label: Text(botonTexto!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
