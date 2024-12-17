import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart';
import 'package:google_maps_webservice/places.dart' as gmaps; 
import 'package:location/location.dart' as loc;


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _defaultCenter = LatLng(45.5231, -122.6765); // Default center on Portland

  // Current user location
  LatLng? _userLocation;

  // Current zoom level
  double _currentZoom = 12.0;

  // Initial map type
  MapType _currentMapType = MapType.normal;

  // Set of markers
  final Set<Marker> _markers = {};

  // Tab controller for switching between Map and Favorites
  late TabController _tabController;

  // Google Places API instance
  final places = GoogleMapsPlaces(apiKey: 'AIzaSyAlx5sC50RFziKxX94fMe6sphvIJ_XIM7E'); // Replace with your API key

  // List of map types
  final List<MapType> _mapTypes = [
    MapType.normal,
    MapType.satellite,
    MapType.terrain,
    MapType.hybrid,
  ];

  // Map type names for display
  final List<String> _mapTypeNames = [
    'Normal',
    'Satellite',
    'Terrain',
    'Hybrid',
  ];

  // Currently selected map type
  String _selectedMapType = 'Normal';

  // List to hold autocomplete results
  List<Prediction> _searchResults = [];

  // List of favorite locations
  final List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeUserLocation(); // Fetch user location when the screen loads
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch the user's current location
  Future<void> _initializeUserLocation() async {
    final location = loc.Location();


    // Check and request permission
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get the current location
    final currentLocation = await location.getLocation();

    setState(() {
      _userLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      _markers.add(
        Marker(
          markerId: const MarkerId('userLocation'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    });

    // Move the map camera to the user's location
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 15.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Colors.blueAccent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: "Map"),
            Tab(icon: Icon(Icons.favorite), text: "Favorites"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMapView(), // Display the map in the "Map" tab
          _buildFavoritesView(), // Updated Favorites tab
        ],
      ),
    );
  }

  // Build the Map View
  Widget _buildMapView() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            if (!_controller.isCompleted) {
              _controller.complete(controller);
            }
          },
          initialCameraPosition: CameraPosition(
            target: _userLocation ?? _defaultCenter, // Use user's location if available
            zoom: _currentZoom,
          ),
          mapType: _currentMapType,
          markers: _markers,
          myLocationEnabled: true, // Enable user location
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false, // Disable default zoom controls
        ),
        // Map type selector
        Positioned(
          top: 20,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _selectedMapType,
              icon: const Icon(Icons.map, color: Colors.blue),
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
            ),
          ),
        ),
        // Zoom buttons
        Positioned(
          bottom: 100,
          right: 10,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'zoomIn',
                onPressed: _zoomIn,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.zoom_in),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'zoomOut',
                onPressed: _zoomOut,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.zoom_out),
              ),
            ],
          ),
        ),
        // Search bar
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
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search here',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                    onChanged: (query) {
                      _performAutocomplete(query); // Call autocomplete on text change
                    },
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
        if (_searchResults.isNotEmpty)
          Positioned(
            bottom: 80,
            left: 10,
            right: 10,
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    title: Text(result.description ?? ''),
                    onTap: () {
                      _selectPlace(result);
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  // Add Zoom In functionality
  Future<void> _zoomIn() async {
    final GoogleMapController controller = await _controller.future;
    setState(() {
      _currentZoom++;
    });
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  // Add Zoom Out functionality
  Future<void> _zoomOut() async {
    final GoogleMapController controller = await _controller.future;
    setState(() {
      _currentZoom--;
    });
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  // Build the Favorites View
  Widget _buildFavoritesView() {
    return Stack(
      children: [
        ListView.builder(
          itemCount: _favorites.length,
          itemBuilder: (context, index) {
            final favorite = _favorites[index];
            return ListTile(
              title: Text(favorite['name']),
              subtitle: Text(favorite['address']),
              trailing: const Icon(Icons.place, color: Colors.blue),
              onTap: () {
                _goToLocation(favorite['position']);
                _tabController.animateTo(0); // Switch back to the map tab
              },
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'addFavorite',
            onPressed: _showAddFavoriteDialog,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  // Show dialog to add a new favorite location
  void _showAddFavoriteDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController latController = TextEditingController();
    final TextEditingController lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Favorite Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final address = addressController.text;
                final double? lat = double.tryParse(latController.text);
                final double? lng = double.tryParse(lngController.text);

                if (name.isNotEmpty && address.isNotEmpty && lat != null && lng != null) {
                  setState(() {
                    _favorites.add({
                      'name': name,
                      'address': address,
                      'position': LatLng(lat, lng),
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Autocomplete function to search for places
  Future<void> _performAutocomplete(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    final response = await places.autocomplete(query);
    if (response.isOkay) {
      setState(() {
        _searchResults = response.predictions;
      });
    } else {
      print('Error: ${response.errorMessage}');
    }
  }

  // Select a place, add marker, and display a popup with details
  Future<void> _selectPlace(Prediction prediction) async {
    final placeDetails = await places.getDetailsByPlaceId(prediction.placeId ?? '');
    final location = placeDetails.result.geometry?.location;

    if (location != null) {
      final LatLng selectedPosition = LatLng(location.lat, location.lng);
      final String? name = placeDetails.result.name;
      final String? address = placeDetails.result.formattedAddress;
      final double? rating = (placeDetails.result.rating)?.toDouble();

      _goToLocation(selectedPosition);

      // Add a marker for the selected place
      setState(() {
        _searchResults = [];
        _markers.add(
          Marker(
            markerId: MarkerId(prediction.placeId ?? ''),
            position: selectedPosition,
            infoWindow: InfoWindow(
              title: name,
              snippet: 'Tap for more info',
              onTap: () {
                _showRatingPopup(name, address, rating);
              },
            ),
          ),
        );
      });

      // Show the rating popup
      _showRatingPopup(name, address, rating);
    }
  }

  // Show a dialog with rating, details, and a Yelp watermark
  void _showRatingPopup(String? name, String? address, double? rating) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name ?? 'No Name Available',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis, // Prevents overflow
                ),
              ),
              SizedBox(
                height: 20,
                width: 50, // Smaller size for the logo
                child: Image.asset(
                  'assets/images/yelp_logo.jpg', // Corrected asset path
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(address ?? 'No Address Available'),
              const SizedBox(height: 10),
              Text('Rating: ${rating?.toStringAsFixed(1) ?? 'N/A'}⭐'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Navigate to the selected place on the map
  void _goToLocation(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 15.0));
  }
}
