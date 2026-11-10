import 'dart:convert';
import 'package:http/http.dart' as http;
import '../post_model.dart';

class PostService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<PostModel>> obtenerPosts() async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/blog'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar publicaciones');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map(
          (json) => PostModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<bool> agregarPost({
    required String titulo,
    required String descripcion,
    String? imagen,
    String? tags,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/blog'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'titulo': titulo,
        'descripcion': descripcion,
        'img': imagen,
        'tags': tags,
      }),
    );

    if (respuesta.statusCode == 201 || respuesta.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al agregar publicación');
    }
  }
}