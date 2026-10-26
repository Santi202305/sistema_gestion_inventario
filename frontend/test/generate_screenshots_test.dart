import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/producto.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/views/producto_form_view.dart';
import 'package:frontend/widgets/confirm_dialog.dart';
import 'package:frontend/widgets/empty_widget.dart';
import 'package:frontend/widgets/error_widget.dart';
import 'package:frontend/widgets/indicador_card.dart';
import 'package:frontend/widgets/loading_widget.dart';
import 'package:frontend/widgets/producto_list_item.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> _loadFonts() async {
  final fontLoader = FontLoader('Roboto');
  for (final filename in [
    'NotoSans-Regular.ttf',
    'NotoSans-Medium.ttf',
    'NotoSans-SemiBold.ttf',
    'NotoSans-Bold.ttf',
  ]) {
    final file = File('/usr/share/fonts/noto/$filename');
    if (file.existsSync()) {
      final bytes = file.readAsBytesSync();
      fontLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
  }
  await fontLoader.load();

  final iconLoader = FontLoader('MaterialIcons');
  final iconFile = File('build/flutter_assets/fonts/MaterialIcons-Regular.otf');
  if (iconFile.existsSync()) {
    final bytes = iconFile.readAsBytesSync();
    iconLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await iconLoader.load();
  }
}

final List<Producto> productosBase = [
  Producto(
    id: 1,
    nombre: 'Mouse Inalámbrico Ergonómico',
    codigo: 'TEC-001',
    descripcion: 'Mouse óptico 2.4GHz con sensor ajustable hasta 1600 DPI y batería recargable',
    precio: 45000.0,
    cantidad: 25,
    categoria: 'Tecnología',
  ),
  Producto(
    id: 2,
    nombre: 'Teclado Mecánico RGB',
    codigo: 'TEC-002',
    descripcion: 'Teclado mecánico compacto con switches azules y retroiluminación personalizable',
    precio: 185000.0,
    cantidad: 14,
    categoria: 'Tecnología',
  ),
  Producto(
    id: 3,
    nombre: 'Monitor LED 24 Pulgadas FHD',
    codigo: 'TEC-003',
    descripcion: 'Monitor panel IPS con resolución 1080p, tasa de refresco 75Hz y entradas HDMI/VGA',
    precio: 520000.0,
    cantidad: 8,
    categoria: 'Tecnología',
  ),
  Producto(
    id: 4,
    nombre: 'Audífonos Bluetooth con Micrófono',
    codigo: 'ACC-001',
    descripcion: 'Diadema inalámbrica con cancelación pasiva de ruido y autonomía de 20 horas',
    precio: 98000.0,
    cantidad: 30,
    categoria: 'Accesorios',
  ),
  Producto(
    id: 5,
    nombre: 'Cable HDMI 2.0 Trenzado 2m',
    codigo: 'ACC-002',
    descripcion: 'Cable de alta velocidad apantallado compatible con 4K Ultra HD y conectores dorados',
    precio: 22000.0,
    cantidad: 45,
    categoria: 'Accesorios',
  ),
  Producto(
    id: 6,
    nombre: 'Resma de Papel Carta 75g',
    codigo: 'PAP-001',
    descripcion: 'Paquete de 500 hojas multiusos para impresión láser e inyección de tinta',
    precio: 18500.0,
    cantidad: 60,
    categoria: 'Papelería',
  ),
  Producto(
    id: 7,
    nombre: 'Cuaderno Argollado 100 Hojas',
    codigo: 'PAP-002',
    descripcion: 'Cuaderno universitario de pasta dura plastificada con hojas cuadriculadas',
    precio: 9500.0,
    cantidad: 50,
    categoria: 'Papelería',
  ),
  Producto(
    id: 8,
    nombre: 'Caja de Bolígrafos Tinta Negra 12u',
    codigo: 'PAP-003',
    descripcion:
        'Bolígrafos punto fino 0.7mm con tinta gel de secado instantáneo',
    precio: 14000.0,
    cantidad: 35,
    categoria: 'Papelería',
  ),
];

final nuevoProducto = Producto(
  id: 13,
  nombre: 'Cámara Web Full HD 1080p',
  codigo: 'CAM-001',
  descripcion:
      'Cámara web con micrófono estéreo y corrección automática de luz',
  precio: 120000.0,
  cantidad: 15,
  categoria: 'Tecnología',
);

void configurePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
    dotenv.loadFromString(envString: 'BASE_URL=http://localhost:3000/api');
  });

  // 01-dashboard.png
  testWidgets('01-dashboard', (WidgetTester tester) async {
    configurePhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard de Inventario'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
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
              IndicadorCard(
                titulo: 'PRODUCTOS REGISTRADOS',
                valor: '12',
                subtitulo: 'Ítems únicos en catálogo',
                icono: Icons.inventory_2_rounded,
                colorPrimario: const Color(0xFF1E3A8A),
              ),
              IndicadorCard(
                titulo: 'UNIDADES EN STOCK',
                valor: '339',
                subtitulo: 'Existencias totales disponibles',
                icono: Icons.inventory_rounded,
                colorPrimario: const Color(0xFF0D9488),
              ),
              IndicadorCard(
                titulo: 'VALOR TOTAL DEL INVENTARIO',
                valor: '\$ 18.592.000',
                subtitulo: 'Calculado: ∑ (precio × cantidad)',
                icono: Icons.account_balance_wallet_rounded,
                colorPrimario: const Color(0xFFD97706),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.format_list_bulleted_rounded),
                        label: const Text('Ver Productos'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Nuevo Producto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/01-dashboard.png'),
    );
  });

  // 02-lista-productos.png
  testWidgets('02-lista-productos', (WidgetTester tester) async {
    configurePhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Catálogo de Productos'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: productosBase.length,
            itemBuilder: (context, index) {
              return ProductoListItem(
                producto: productosBase[index],
                onTap: () {},
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nuevo'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/02-lista-productos.png'),
    );
  });

  // 03-detalle-producto.png
  testWidgets('03-detalle-producto', (WidgetTester tester) async {
    configurePhone(tester);
    final p = productosBase[0];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Detalle del Producto'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.red.shade200,
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
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
                                color: const Color(0xFF1E3A8A)
                                    .withValues(alpha: 0.1),
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Card(
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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.12),
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
                Card(
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
                          p.descripcion!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Editar Producto'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete_forever_rounded),
                        label: const Text('Eliminar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/03-detalle-producto.png'),
    );
  });

  // 04-formulario-registro.png
  testWidgets('04-formulario-registro', (WidgetTester tester) async {
    configurePhone(tester);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const ProductoFormView()),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/04-formulario-registro.png'),
    );
  });

  // 05-formulario-errores-validacion.png
  testWidgets('05-formulario-errores-validacion', (WidgetTester tester) async {
    configurePhone(tester);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const ProductoFormView()),
    );
    await tester.pumpAndSettle();

    // Tocar el botón de guardar sin rellenar campos
    await tester.tap(find.text('Registrar Producto'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        '../../docs/screenshots/05-formulario-errores-validacion.png',
      ),
    );
  });

  // 06-producto-creado.png
  testWidgets('06-producto-creado', (WidgetTester tester) async {
    configurePhone(tester);
    final listaConNuevo = [nuevoProducto, ...productosBase];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(title: const Text('Catálogo de Productos')),
              body: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: listaConNuevo.length,
                itemBuilder: (ctx, idx) => ProductoListItem(
                  producto: listaConNuevo[idx],
                  onTap: () {},
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nuevo'),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Mostrar SnackBar de producto creado
    final scaffoldContext = tester.element(find.byType(Scaffold));
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      const SnackBar(
        content: Text(
          'Producto "Cámara Web Full HD 1080p" registrado con éxito',
        ),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 10),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/06-producto-creado.png'),
    );
  });

  // 07-formulario-edicion.png
  testWidgets('07-formulario-edicion', (WidgetTester tester) async {
    configurePhone(tester);
    final p = productosBase[0];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(title: const Text('Editar Producto')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: p.codigo,
                  decoration: const InputDecoration(
                    labelText: 'Código único *',
                    prefixIcon: Icon(Icons.qr_code_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: p.nombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto *',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: p.categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría *',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: p.precio.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Precio (COP) *',
                          prefixIcon: Icon(Icons.attach_money_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: p.cantidad.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Cantidad *',
                          prefixIcon: Icon(Icons.format_list_numbered_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: p.descripcion,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción adicional (opcional)',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'Actualizar Producto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/07-formulario-edicion.png'),
    );
  });

  // 08-producto-editado.png
  testWidgets('08-producto-editado', (WidgetTester tester) async {
    configurePhone(tester);
    final pEditado = productosBase[0].copyWith(
      nombre: 'Mouse Inalámbrico Ergonómico Pro',
      precio: 52000.0,
      cantidad: 20,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Detalle del Producto'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.red.shade200,
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
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
                                color: const Color(0xFF1E3A8A)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pEditado.codigo,
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
                                pEditado.categoria,
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
                          pEditado.nombre,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Identificador ID: #${pEditado.id}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Card(
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
                                pEditado.precioFormateado,
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
                                '${pEditado.cantidad} unidades',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.12),
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
                              pEditado.valorTotalFormateado,
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
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scaffoldContext = tester.element(find.byType(Scaffold));
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      const SnackBar(
        content: Text(
          'Producto "Mouse Inalámbrico Ergonómico Pro" actualizado con éxito',
        ),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 10),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/08-producto-editado.png'),
    );
  });

  // 09-confirmacion-eliminar.png
  testWidgets('09-confirmacion-eliminar', (WidgetTester tester) async {
    configurePhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(title: const Text('Detalle del Producto')),
          body: const Stack(
            children: [
              Center(child: Text('Fondo detalle')),
              ModalBarrier(color: Colors.black54, dismissible: false),
              Center(
                child: ConfirmDialog(
                  titulo: '¿Eliminar producto?',
                  mensaje: '¿Está seguro de que desea eliminar "Mouse Inalámbrico Ergonómico"? Esta acción no se puede deshacer.',
                  textoConfirmar: 'Eliminar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/09-confirmacion-eliminar.png'),
    );
  });

  // 10-producto-eliminado.png
  testWidgets('10-producto-eliminado', (WidgetTester tester) async {
    configurePhone(tester);
    final listaSinPrimero = productosBase.sublist(1);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(title: const Text('Catálogo de Productos')),
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: listaSinPrimero.length,
            itemBuilder: (ctx, idx) =>
                ProductoListItem(producto: listaSinPrimero[idx], onTap: () {}),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nuevo'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scaffoldContext = tester.element(find.byType(Scaffold));
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      const SnackBar(
        content: Text(
          'Producto "Mouse Inalámbrico Ergonómico" eliminado correctamente',
        ),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 10),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/10-producto-eliminado.png'),
    );
  });

  // 11-dashboard-actualizado.png
  testWidgets('11-dashboard-actualizado', (WidgetTester tester) async {
    configurePhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(title: const Text('Dashboard de Inventario')),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
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
              IndicadorCard(
                titulo: 'PRODUCTOS REGISTRADOS',
                valor: '13',
                subtitulo: 'Ítems únicos en catálogo (+1 registrado)',
                icono: Icons.inventory_2_rounded,
                colorPrimario: const Color(0xFF1E3A8A),
              ),
              IndicadorCard(
                titulo: 'UNIDADES EN STOCK',
                valor: '351',
                subtitulo: 'Existencias totales (+12 unds)',
                icono: Icons.inventory_rounded,
                colorPrimario: const Color(0xFF0D9488),
              ),
              IndicadorCard(
                titulo: 'VALOR TOTAL DEL INVENTARIO',
                valor: '\$ 20.212.000',
                subtitulo: 'Actualizado tras operaciones CRUD',
                icono: Icons.account_balance_wallet_rounded,
                colorPrimario: const Color(0xFFD97706),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.format_list_bulleted_rounded),
                        label: const Text('Ver Productos'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Nuevo Producto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/11-dashboard-actualizado.png'),
    );
  });

  // 12-estado-carga.png
  testWidgets('12-estado-carga', (WidgetTester tester) async {
    configurePhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(title: const Text('Dashboard de Inventario')),
          body: const LoadingWidget(
            mensaje: 'Cargando indicadores de inventario...',
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/12-estado-carga.png'),
    );
  });

  // 13-estado-error.png
  testWidgets('13-estado-error', (WidgetTester tester) async {
    configurePhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(title: const Text('Dashboard de Inventario')),
          body: CustomErrorWidget(
            mensaje: 'No se pudo conectar con el servidor. Verifique que el backend esté en ejecución.',
            onRetry: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/13-estado-error.png'),
    );
  });

  // 14-estado-vacio.png
  testWidgets('14-estado-vacio', (WidgetTester tester) async {
    configurePhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(title: const Text('Catálogo de Productos')),
          body: EmptyWidget(
            titulo: 'Sin productos registrados',
            mensaje: 'No hay productos en la base de datos. Comienza registrando el primero.',
            botonTexto: 'Registrar Producto',
            onBotonPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/14-estado-vacio.png'),
    );
  });
}
