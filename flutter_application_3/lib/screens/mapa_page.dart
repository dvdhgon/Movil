import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  // Coordenadas del centro de Querétaro
  static const LatLng centroQueretaro = LatLng(20.5888, -100.3899);

  // 3 marcadores requeridos por la práctica
  final Set<Marker> marcadores = {
    const Marker(
      markerId: MarkerId('centro_queretaro'),
      position: LatLng(20.5888, -100.3899),
      infoWindow: InfoWindow(
        title: 'Centro Histórico',
        snippet: 'Ubicación de referencia en Querétaro',
      ),
    ),
    const Marker(
      markerId: MarkerId('uteq'),
      position: LatLng(20.6173, -100.3910),
      infoWindow: InfoWindow(
        title: 'UTEQ',
        snippet: 'Universidad Tecnológica de Querétaro',
      ),
    ),
    const Marker(
      markerId: MarkerId('parque_alameda'),
      position: LatLng(20.5875, -100.3880),
      infoWindow: InfoWindow(
        title: 'Parque Alameda',
        snippet: 'Lugar de interés de la comunidad',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lugares de mi comunidad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: centroQueretaro,
          zoom: 14,
        ),
        markers: marcadores,
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          debugPrint('Mapa de Google cargado correctamente');
        },
      ),
    );
  }
}