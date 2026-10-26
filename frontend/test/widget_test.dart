import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/producto.dart';

void main() {
  group('Pruebas unitarias de modelo Producto', () {
    test('fromJson convierte correctamente tipos numéricos y strings', () {
      final json = {
        'id': '10',
        'nombre': 'Teclado Mecánico',
        'codigo': 'TEC-99',
        'descripcion': 'Teclado gamer',
        'precio': '150000.50',
        'cantidad': '15',
        'categoria': 'Tecnología',
      };

      final producto = Producto.fromJson(json);

      expect(producto.id, equals(10));
      expect(producto.nombre, equals('Teclado Mecánico'));
      expect(producto.codigo, equals('TEC-99'));
      expect(producto.descripcion, equals('Teclado gamer'));
      expect(producto.precio, equals(150000.50));
      expect(producto.cantidad, equals(15));
      expect(producto.categoria, equals('Tecnología'));
      expect(producto.valorTotal, equals(150000.50 * 15));
    });

    test('toJson genera la estructura correcta para la API', () {
      final producto = Producto(
        id: 5,
        nombre: 'Mouse Óptico',
        codigo: 'MOU-01',
        precio: 35000.0,
        cantidad: 20,
        categoria: 'Accesorios',
      );

      final json = producto.toJson();

      expect(json['nombre'], equals('Mouse Óptico'));
      expect(json['codigo'], equals('MOU-01'));
      expect(json['precio'], equals(35000.0));
      expect(json['cantidad'], equals(20));
      expect(json['categoria'], equals('Accesorios'));
      expect(json.containsKey('id'), isFalse);
    });
  });
}
