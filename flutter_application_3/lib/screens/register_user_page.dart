import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/services/user_service.dart';
import '../widgets/admin_drawer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final UserService userService = UserService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  int _tipoUsuario = 2; // Default: Usuario Normal (2)
  bool cargando = false;

  Map<String, dynamic> usuarioActual = {};
  bool argumentoLeido = false;

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

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  Future<void> registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => cargando = true);

    try {
      final nuevoUsuario = UserModel(
        id: 0,
        nombre: nombreController.text.trim(),
        correo: correoController.text.trim().toLowerCase(),
        password: passwordController.text,
        direccion: direccionController.text.trim().isEmpty
            ? 'Sin dirección'
            : direccionController.text.trim(),
        tipoUsuario: _tipoUsuario,
      );

      await userService.agregarUsuario(nuevoUsuario);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Usuario registrado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );

      if (esAdmin) {
        Navigator.pushReplacementNamed(
          context,
          '/users',
          arguments: usuarioActual,
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => cargando = false);
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
        title: const Text('Registrar Usuario'),
      ),
      drawer: esAdmin
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/register')
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
                  const Icon(
                    Icons.person_add,
                    size: 60,
                    color: Color(0xFF08245C),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: correoController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Correo inválido'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.length < 8 ? 'Mínimo 8 caracteres' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _tipoUsuario,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de usuario',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 2,
                        child: Text('Usuario Normal'),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Administrador'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _tipoUsuario = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  cargando
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF08245C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: registrarUsuario,
                            child: const Text(
                              'REGISTRAR',
                              style: TextStyle(color: Colors.white),
                            ),
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