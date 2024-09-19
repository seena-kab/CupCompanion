// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously
import 'package:cup_companion/services/auth_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = LatLng(45.5231, -122.6765); // Center on Portland

  // Current zoom level
  double _currentZoom = 12.0;

  // Initial map type
  MapType _currentMapType = MapType.normal;

  // Set of markers (e.g., sample marker in Portland)
  Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('portland'),
      position: _center,
      infoWindow: InfoWindow(
        title: 'Portland',
        snippet: 'A nice place to visit!',
      ),
    ),
  };

  // List of map types for the dropdown menu
  final List<MapType> _mapTypes = [
    MapType.normal,
    MapType.satellite,
    MapType.terrain,
    MapType.hybrid,
  ];

  // Map type names for the dropdown menu display
  final List<String> _mapTypeNames = [
    'Normal',
    'Satellite',
    'Terrain',
    'Hybrid',
  ];

  // Selected map type name
  String _selectedMapType = 'Normal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: _currentZoom,
            ),
            mapType: _currentMapType,
            markers: _markers,
          ),
          // Layer button, zoom controls, and map type dropdown
          Positioned(
            top: 100,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  onPressed: () => _zoomIn(),
                  child: const Icon(Icons.zoom_in),
                  backgroundColor: Colors.blue[700],
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  onPressed: () => _zoomOut(),
                  child: const Icon(Icons.zoom_out),
                  backgroundColor: Colors.blue[700],
                ),
                const SizedBox(height: 10),
                _buildMapTypeDropdown(),
              ],
            ),
          ),
          // Bottom search/filter bar
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search here',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    color: Colors.grey,
                    onPressed: () {
                      // Filter button action
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build dropdown menu for selecting map type
  Widget _buildMapTypeDropdown() {
    return DropdownButton<String>(
      value: _selectedMapType,
      icon: Icon(Icons.map, color: Colors.blue[700]),
      items: _mapTypeNames.map((String mapTypeName) {
        return DropdownMenuItem<String>(
          value: mapTypeName,
          child: Text(mapTypeName),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedMapType = newValue!;
          _currentMapType = _mapTypes[_mapTypeNames.indexOf(_selectedMapType)];
        });
      },
    );
  }

  // Zoom in
  void _zoomIn() async {
    final GoogleMapController controller = await _controller.future;
    setState(() {
      _currentZoom++;
    });
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  // Zoom out
  void _zoomOut() async {
    final GoogleMapController controller = await _controller.future;
    setState(() {
      _currentZoom--;
    });
    controller.animateCamera(CameraUpdate.zoomOut());
  }
}
