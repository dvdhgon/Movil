class UserModel {
  final int? id; // Ahora es opcional (int?) para evitar fallos si no existe ID aún
  final String nombre;
  final String correo;
  final String? password;
  final String? direccion;
  final int tipoUsuario;

  UserModel({
    this.id,
    required this.nombre,
    required this.correo,
    this.password,
    this.direccion,
    this.tipoUsuario = 1,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Conversión segura de ID para evitar crash por tipos numéricos o nulos
    final rawId = json['id_usr'] ?? json['id_usuario'] ?? json['id'];
    final int? parsedId = rawId != null ? int.tryParse(rawId.toString()) : null;

    return UserModel(
      id: parsedId,
      nombre: (json['nom_usr'] ?? json['nombre'] ?? '').toString(),
      correo: (json['mail'] ?? json['correo'] ?? '').toString(),
      password: json['password']?.toString(),
      direccion: json['dir_usr']?.toString() ?? json['direccion']?.toString(),
      tipoUsuario: (json['tip_usu'] as num? ?? 1).toInt(),
    );
  }

  // Estructura para registrar / crear un usuario nuevo
  Map<String, dynamic> toJsonCrear() {
    return {
      'nom_usr': nombre,
      'mail': correo,
      'password': password ?? '12345678',
      'dir_usr': direccion,
      'tip_usu': tipoUsuario,
    };
  }

  // Estructura para actualizar perfil en el backend (sin contraseña)
  Map<String, dynamic> toJsonActualizar() {
    return {
      'nom_usr': nombre,
      'mail': correo,
      'dir_usr': direccion,
      'tip_usu': tipoUsuario,
    };
  }

  Map<String, dynamic> toJson() => toJsonActualizar();
}