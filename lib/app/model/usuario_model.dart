class UsuarioModel {
  final String userid;
  final String nombre;
  final String apellido;
  final String dni;
  final String email;
  final String telefono;
  final String rol;
  final bool activo;
  final DateTime? createdat;

  UsuarioModel({
    required this.userid,
    required this.nombre,
    required this.apellido,
    required this.dni,
    required this.email,
    required this.telefono,
    required this.rol,
    required this.activo,
    this.createdat,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      userid: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      dni: json['dni'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      rol: json['rol'] ?? '',
      activo: json['activo'] ?? true,
      createdat: json['createdat'] != null ? DateTime.tryParse(json['createdat']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userid,
      'nombre': nombre,
      'apellido': apellido,
      'dni': dni,
      'email': email,
      'telefono': telefono,
      'rol': rol,
      'activo': activo,
      'createdat': createdat?.toIso8601String(),
    };
  }
}
