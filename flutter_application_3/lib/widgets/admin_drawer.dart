import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final String rutaActual;

  const AdminDrawer({
    super.key,
    required this.usuario,
    required this.rutaActual,
  });

  String get nombre =>
      usuario['nom_usr']?.toString() ??
      usuario['nombre']?.toString() ??
      'Administrador';

  String get correo =>
      usuario['mail']?.toString() ??
      usuario['correo']?.toString() ??
      '';

  void _navegar(BuildContext context, String ruta) {
    Navigator.pop(context); // Cierra el Drawer
    if (ruta == rutaActual) return;
    Navigator.pushReplacementNamed(
      context,
      ruta,
      arguments: usuario,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Cabecera con datos del usuario
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 45, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF08245C),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Color(0xFF08245C),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (correo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    correo,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Lista Completa de Opciones de Navegación
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _opcion(
                  context,
                  Icons.article_outlined,
                  'Ver Blog',
                  '/blog',
                ),
                _opcion(
                  context,
                  Icons.group_outlined,
                  'Gestión de usuarios',
                  '/users',
                ),
                _opcion(
                  context,
                  Icons.person_add_alt_1_outlined,
                  'Registrar usuario',
                  '/register',
                ),
                _opcion(
                  context,
                  Icons.post_add,
                  'Agregar blog',
                  '/add-blog',
                ),
                _opcion(
                  context,
                  Icons.map_outlined,
                  'Mapa de lugares',
                  '/mapa',
                ),
                _opcion(
                  context,
                  Icons.account_circle_outlined,
                  'Mi perfil',
                  '/profile',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Botón de Cerrar Sesión
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: const Icon(Icons.logout, color: Color(0xFFFF5252)),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(
                color: Color(0xFFFF5252),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _opcion(
    BuildContext context,
    IconData icono,
    String titulo,
    String ruta,
  ) {
    final seleccionado = ruta == rutaActual;
    const colorSeleccionado = Color(0xFF6750A4);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(
        icono,
        color: seleccionado ? colorSeleccionado : Colors.black87,
        size: 26,
      ),
      title: Text(
        titulo,
        style: TextStyle(
          color: seleccionado ? colorSeleccionado : Colors.black87,
          fontSize: 16,
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: seleccionado,
      onTap: () => _navegar(context, ruta),
    );
  }
}