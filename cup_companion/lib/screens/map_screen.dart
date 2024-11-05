import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = LatLng(45.5231, -122.6765);
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: 'YOUR_API_KEY'); // Replace with your API key

  double _currentZoom = 12.0;
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};
  late TabController _tabController;

  // List of coffee places with name, address, and position
  List<Map<String, dynamic>> _coffeePlaces = [
    {
      'name': 'Stumptown Coffee Roasters',
      'address': '123 Coffee St, Portland, OR',
      'position': const LatLng(45.521563, -122.677433),
    },
    {
      'name': 'Heart Coffee Roasters',
      'address': '456 Bean Ave, Portland, OR',
      'position': const LatLng(45.523751, -122.681507),
    },
    {
      'name': 'Coava Coffee Roasters',
      'address': '789 Roast Rd, Portland, OR',
      'position': const LatLng(45.526424, -122.675485),
    },
  ];

  // Default map style for day and night
  String? _mapStyle;

  // Controller for search bar
  final TextEditingController _searchController = TextEditingController();
  List<Prediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _addInitialMarkers();
    _loadMapStyle();
  }

  void _loadMapStyle() async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    if (themeNotifier.isNightMode) {
      _mapStyle = await DefaultAssetBundle.of(context).loadString('assets/map_styles/night.json');
    } else {
      _mapStyle = await DefaultAssetBundle.of(context).loadString('assets/map_styles/day.json');
    }
    setState(() {}); // Update the map style by triggering a rebuild
  }

  @override
  void dispose() {
    _tabController.dispose();
    _places.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: themeNotifier.isNightMode ? Colors.black : Colors.blueAccent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: "Map"),
            Tab(icon: Icon(Icons.favorite), text: "Favorites"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMapView(),
                _buildCoffeeListView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () => _showAddPlaceDialog(context),
              child: const Icon(Icons.add),
              backgroundColor: themeNotifier.isNightMode ? Colors.amber : Colors.blue,
            )
          : null,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for a place',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              _getAutocompleteSuggestions(value);
            },
          ),
          if (_predictions.isNotEmpty)
            Container(
              color: Colors.white,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _predictions.length,
                itemBuilder: (context, index) {
                  final prediction = _predictions[index];
                  return ListTile(
                    title: Text(prediction.description ?? ""),
                    onTap: () {
                      _selectPrediction(prediction);
                      _searchController.clear();
                      setState(() {
                        _predictions = [];
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _getAutocompleteSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    final response = await _places.autocomplete(input);
    if (response.isOkay) {
      setState(() {
        _predictions = response.predictions;
      });
    } else {
      setState(() {
        _predictions = [];
      });
    }
  }

  Future<void> _selectPrediction(Prediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId != null) {
      final response = await _places.getDetailsByPlaceId(placeId);
      if (response.isOkay) {
        final result = response.result;
        final latLng = LatLng(result.geometry!.location.lat, result.geometry!.location.lng);

        // Add a marker for the selected place and move the camera
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(result.name),
              position: latLng,
              infoWindow: InfoWindow(
                title: result.name,
                snippet: result.formattedAddress,
              ),
            ),
          );
        });

        final controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15.0));
      }
    }
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: _currentZoom,
            ),
            mapType: _currentMapType,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            style: _mapStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildCoffeeListView() {
    return ListView.builder(
      itemCount: _coffeePlaces.length,
      itemBuilder: (context, index) {
        final coffeePlace = _coffeePlaces[index];
        return ListTile(
          title: Text(coffeePlace['name']),
          subtitle: Text(coffeePlace['address']),
          trailing: const Icon(Icons.local_cafe, color: Colors.brown),
          onTap: () {
            _goToLocation(coffeePlace['position']);
            _tabController.animateTo(0);
          },
        );
      },
    );
  }

  void _addInitialMarkers() {
    setState(() {
      for (var place in _coffeePlaces) {
        _markers.add(
          Marker(
            markerId: MarkerId(place['name'] as String),
            position: place['position'] as LatLng,
            infoWindow: InfoWindow(
              title: place['name'] as String,
              snippet: place['address'] as String,
            ),
          ),
        );
      }
    });
  }

  void _showAddPlaceDialog(BuildContext context) {
    final TextEditingController _addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add a New Place'),
        content: TextField(
          controller: _addressController,
          decoration: const InputDecoration(hintText: 'Enter address'),
          onSubmitted: (_) => _searchPlace(_addressController.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _searchPlace(_addressController.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _searchPlace(String address) async {
    final response = await _places.searchByText(address);
    if (response.isOkay && response.results.isNotEmpty) {
      final result = response.results.first;
      final latLng = LatLng(result.geometry!.location.lat, result.geometry!.location.lng);

      setState(() {
        _coffeePlaces.add({
          'name': result.name,
          'address': address,
          'position': latLng,
        });
        _markers.add(
          Marker(
            markerId: MarkerId(result.name),
            position: latLng,
            infoWindow: InfoWindow(
              title: result.name,
              snippet: address,
            ),
          ),
        );
      });

      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15.0));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No results found for that address')),
      );
    }
  }

  void _goToLocation(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 15.0));
  }
}
