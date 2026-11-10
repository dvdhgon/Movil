import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/services/user_service.dart';
import '../widgets/admin_drawer.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserService userService = UserService();
  late Future<List<UserModel>> futureUsuarios;

  Map<String, dynamic> usuarioActual = {
    'nom_usr': 'adriana',
    'mail': '',
    'tip_usu': 1,
  };
  bool argumentoLeido = false;

  @override
  void initState() {
    super.initState();
    futureUsuarios = userService.obtenerUsuarios();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!argumentoLeido) {
      final argumento = ModalRoute.of(context)?.settings.arguments;

      if (argumento is Map<String, dynamic>) {
        usuarioActual = Map<String, dynamic>.from(argumento);
      }

      argumentoLeido = true;
    }
  }

  void recargarUsuarios() {
    setState(() {
      futureUsuarios = userService.obtenerUsuarios();
    });
  }

  bool get esAdmin {
    final tipUsu = usuarioActual['tip_usu'];
    return tipUsu == 1 || tipUsu.toString() == '1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
            onPressed: recargarUsuarios,
          ),
        ],
      ),
      drawer: esAdmin
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/users')
          : null,
      body: FutureBuilder<List<UserModel>>(
        future: futureUsuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Error al cargar usuarios: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: recargarUsuarios,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final usuarios = snapshot.data ?? [];

          if (usuarios.isEmpty) {
            return const Center(
              child: Text('No hay usuarios registrados.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: usuarios.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final usr = usuarios[index];
              final bool isAdmin =
                  usr.tipoUsuario == 1 || usr.tipoUsuario.toString() == '1';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF08245C),
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  usr.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(usr.correo),
                trailing: Chip(
                  label: Text(
                    isAdmin ? 'Admin' : 'Usuario',
                    style: TextStyle(
                      color: isAdmin ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor:
                      isAdmin ? const Color(0xFF08245C) : Colors.grey[200],
                ),
              );
            },
          );
        },
      ),
    );
  }
}