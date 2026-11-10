import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/services/user_service.dart';
import '../widgets/admin_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService userService = UserService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _dirCtrl;

  Map<String, dynamic> usuarioActual = {};
  bool argumentoLeido = false;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController();
    _dirCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _dirCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!argumentoLeido) {
      final argumento = ModalRoute.of(context)?.settings.arguments;
      if (argumento is Map<String, dynamic>) {
        usuarioActual = Map<String, dynamic>.from(argumento);
        _nombreCtrl.text = usuarioActual['nom_usr'] ?? usuarioActual['nombre'] ?? '';
        _dirCtrl.text = usuarioActual['dir_usr'] ?? usuarioActual['direccion'] ?? '';
      }
      argumentoLeido = true;
    }
  }

  void _actualizarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _cargando = true);

    try {
      final rawId = usuarioActual['id_usr'] ?? usuarioActual['id_usuario'] ?? usuarioActual['id'] ?? 1;
      final int idUsr = int.parse(rawId.toString());

      // Validar correo: Si viene vacío ('') o menor a 5 caracteres, asignar fallback válido
      String correoFinal = (usuarioActual['mail'] ?? usuarioActual['correo'] ?? '').toString().trim();
      if (correoFinal.length < 5) {
        correoFinal = 'usuario@gmail.com';
      }

      final usuarioEditado = UserModel(
        id: idUsr,
        nombre: _nombreCtrl.text.trim(),
        correo: correoFinal,
        direccion: _dirCtrl.text.trim().isEmpty ? null : _dirCtrl.text.trim(),
        tipoUsuario: (usuarioActual['tip_usu'] as num? ?? 1).toInt(),
      );

      final usuarioActualizado = await userService.actualizarUsuario(usuarioEditado);

      if (mounted) {
        setState(() {
          usuarioActual['id_usr'] = usuarioActualizado.id;
          usuarioActual['nom_usr'] = usuarioActualizado.nombre;
          usuarioActual['dir_usr'] = usuarioActualizado.direccion;
          usuarioActual['mail'] = usuarioActualizado.correo;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  bool get esAdmin {
    final tipUsu = usuarioActual['tip_usu'];
    return tipUsu == 1 || tipUsu.toString() == '1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      drawer: esAdmin
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/profile')
          : null,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFECE6F0),
                    child: Icon(Icons.person, size: 40, color: Color(0xFF49454F)),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dirCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Dirección (Opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _cargando
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3EDF7),
                              foregroundColor: const Color(0xFF6750A4),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: const BorderSide(color: Color(0xFF79747E)),
                              ),
                            ),
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar cambios'),
                            onPressed: _actualizarPerfil,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}