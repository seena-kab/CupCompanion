// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously
import 'package:cup_companion/services/auth_services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cup_companion/screens/home_screen.dart';
import 'package:cup_companion/screens/settings_screen.dart';
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

  // Default center position (e.g., San Francisco)
  static const LatLng _center = LatLng(37.7749, -122.4194);

  // Initial map type
  MapType _currentMapType = MapType.normal;

  // Set of markers on the map
  Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('_center'),
      position: _center,
      infoWindow: InfoWindow(
        title: 'San Francisco',
        snippet: 'An interesting city!',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[900] : Colors.blueAccent,
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: const CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        mapType: _currentMapType,
        markers: _markers,
        onTap: _handleTap,
        // Apply dark or light map styles based on the theme
        mapToolbarEnabled: false,
        zoomControlsEnabled: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _changeMapType,
        label: const Text('Change Map Type'),
        icon: const Icon(Icons.map),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[700] : Colors.blue,
      ),
    );
  }

  // Change the map type between normal and satellite
  void _changeMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  // Add a marker where the map is tapped
  void _handleTap(LatLng tappedPoint) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          infoWindow: InfoWindow(
            title: 'New Marker',
            snippet: '${tappedPoint.latitude}, ${tappedPoint.longitude}',
          ),
        ),
      );
    });
  }
}
