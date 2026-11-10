import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../widgets/admin_drawer.dart';

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _foto;
  Uint8List? _imagenBytes;
  bool _cargando = false;

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
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // Menú para elegir origen de la imagen (Cámara o Galería/Dispositivo)
  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF08245C)),
                title: const Text('Seleccionar del dispositivo / galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF08245C)),
                title: const Text('Tomar foto con la cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _seleccionarImagen(ImageSource origen) async {
    try {
      final imagen = await _picker.pickImage(
        source: origen,
        imageQuality: 75,
      );

      if (imagen != null) {
        final bytes = await imagen.readAsBytes();
        setState(() {
          _foto = imagen;
          _imagenBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<void> _enviarPublicacion() async {
    if (!_formKey.currentState!.validate()) return;

    if (_foto == null || _imagenBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fotografía de tu dispositivo.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final uri = Uri.parse('http://127.0.0.1:8000/blog');
      final request = http.MultipartRequest('POST', uri)
        ..fields['titulo'] = _tituloCtrl.text.trim()
        ..fields['descripcion'] = _descCtrl.text.trim()
        ..files.add(
          http.MultipartFile.fromBytes(
            'imagen',
            _imagenBytes!,
            filename: _foto!.name,
          ),
        );

      final responseStream = await request.send();
      final response = await http.Response.fromStream(responseStream);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Publicación creada exitosamente en MySQL!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Error del servidor: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
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
        title: const Text('Nueva Publicación'),
      ),
      drawer: esAdmin
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/add_blog')
          : null,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
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
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título del Blog',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'El título es obligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'La descripción es obligatoria' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  // Vista previa de la foto
                  if (_imagenBytes != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _imagenBytes!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                          onPressed: () => setState(() {
                            _foto = null;
                            _imagenBytes = null;
                          }),
                        ),
                      ],
                    )
                  else
                    InkWell(
                      onTap: _mostrarOpcionesImagen,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Color(0xFF08245C)),
                            SizedBox(height: 8),
                            Text('Toca aquí para seleccionar una foto'),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _mostrarOpcionesImagen,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Elegir Imagen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF08245C),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _cargando
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF08245C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: _enviarPublicacion,
                            child: const Text('PUBLICAR'),
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