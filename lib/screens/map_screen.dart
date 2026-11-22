import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // CAMBIA estos datos por la ubicación real de tu negocio.
  static const _storeName = 'Mi Tienda';
  static const _storeAddress = 'Calle Ejemplo 123, Centro';
  static const _store = LatLng(19.4326, -99.1332);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuestra ubicación')),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: _store,
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tuapellido.proyecto_final',
              ),
              const MarkerLayer(
                markers: [
                  Marker(
                    point: _store,
                    width: 48,
                    height: 48,
                    child: Icon(Icons.location_on, size: 48, color: Colors.red),
                  ),
                ],
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.storefront),
                title: const Text(_storeName),
                subtitle: const Text(_storeAddress),
              ),
            ),
          ),
        ],
      ),
    );
  }
}