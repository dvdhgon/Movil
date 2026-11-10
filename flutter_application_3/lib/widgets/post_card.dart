import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  // Función auxiliar para construir la imagen correctamente
  Widget _construirImagen(String? ruta) {
    if (ruta == null || ruta.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey.shade200,
        child: const Center(
            child: Icon(Icons.image_not_supported,
                size: 50, color: Colors.grey)),
      );
    }

    // Concatenar la URL local si la imagen viene del backend FastAPI
    final urlFinal =
        ruta.startsWith('http') ? ruta : 'http://127.0.0.1:8000$ruta';

    return Image.network(
      urlFinal,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 200,
        color: Colors.grey.shade200,
        child: const Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cambiamos post.img por post.imagen
            _construirImagen(post.imagen), 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Se quitó el ?? 'Sin título' porque post.titulo no es nulo
                    post.titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF08245C),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Se quitó el ?? 'Sin descripción'
                    post.descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}