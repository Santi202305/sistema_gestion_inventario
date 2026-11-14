/// Modelo que representa un Usuario autenticado en el sistema
class Usuario {
  final int id;
  final String nombre;
  final String email;

  const Usuario({required this.id, required this.nombre, required this.email});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'email': email};
  }

  @override
  String toString() => 'Usuario(id: $id, nombre: $nombre, email: $email)';
}
