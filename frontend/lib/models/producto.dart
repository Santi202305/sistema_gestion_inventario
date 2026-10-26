class Producto {
  final int? id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final double precio;
  final int cantidad;
  final String categoria;

  Producto({
    this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    required this.precio,
    required this.cantidad,
    required this.categoria,
  });

  /// Crea una instancia de Producto desde un mapa JSON con conversión segura de tipos.
  factory Producto.fromJson(Map<String, dynamic> json) {
    // Conversión segura de id
    int? parsedId;
    if (json['id'] != null) {
      if (json['id'] is int) {
        parsedId = json['id'] as int;
      } else {
        parsedId = int.tryParse(json['id'].toString());
      }
    }

    // Conversión segura de precio (int, double o String)
    double parsedPrecio = 0.0;
    if (json['precio'] != null) {
      if (json['precio'] is num) {
        parsedPrecio = (json['precio'] as num).toDouble();
      } else {
        parsedPrecio = double.tryParse(json['precio'].toString()) ?? 0.0;
      }
    }

    // Conversión segura de cantidad (int, double o String)
    int parsedCantidad = 0;
    if (json['cantidad'] != null) {
      if (json['cantidad'] is num) {
        parsedCantidad = (json['cantidad'] as num).toInt();
      } else {
        parsedCantidad = int.tryParse(json['cantidad'].toString()) ?? 0;
      }
    }

    return Producto(
      id: parsedId,
      nombre: json['nombre']?.toString() ?? '',
      codigo: json['codigo']?.toString() ?? '',
      descripcion:
          json['descripcion'] != null &&
              json['descripcion'].toString().trim().isNotEmpty
          ? json['descripcion'].toString().trim()
          : null,
      precio: parsedPrecio,
      cantidad: parsedCantidad,
      categoria: json['categoria']?.toString() ?? '',
    );
  }

  /// Serializa el objeto Producto a JSON para enviar en peticiones HTTP.
  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = <String, dynamic>{
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'precio': precio,
      'cantidad': cantidad,
      'categoria': categoria,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Clona el producto modificando ciertos campos.
  Producto copyWith({
    int? id,
    String? nombre,
    String? codigo,
    String? descripcion,
    double? precio,
    int? cantidad,
    String? categoria,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
      categoria: categoria ?? this.categoria,
    );
  }

  /// Valor total en inventario de este producto (precio × cantidad)
  double get valorTotal => precio * cantidad;

  /// Formato de moneda para pesos colombianos (ej. $ 45.000)
  String get precioFormateado => Producto.formatearMoneda(precio);
  String get valorTotalFormateado => Producto.formatearMoneda(valorTotal);

  static String formatearMoneda(double valor) {
    final partes = valor.toStringAsFixed(0);
    final buffer = StringBuffer();
    int cont = 0;
    for (int i = partes.length - 1; i >= 0; i--) {
      buffer.write(partes[i]);
      cont++;
      if (cont % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return '\$ ${buffer.toString().split('').reversed.join('')}';
  }
}
