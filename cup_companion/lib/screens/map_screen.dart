import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = LatLng(45.5231, -122.6765); // Center on Portland

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

  // List to hold autocomplete results
  List<Prediction> _searchResults = [];

  // List of coffee places
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _addInitialMarkers(); // Add markers for coffee places when the map loads
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          Stack(
            children: [
              _buildFavoritesView(), // Display the coffee list in the "Favorites" tab with scrolling enabled
              _buildAddFavoriteFAB(), // Add the FAB to allow adding new favorites
            ],
          ),
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
            target: _center,
            zoom: _currentZoom,
          ),
          mapType: _currentMapType,
          markers: _markers,
          myLocationEnabled: true, // Enable user location
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
        ),
        Positioned(
          top: 100,
          right: 10,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'zoomIn',
                onPressed: () => _zoomIn(),
                backgroundColor: Colors.blue[700],
                child: const Icon(Icons.zoom_in),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'zoomOut',
                onPressed: () => _zoomOut(),
                backgroundColor: Colors.blue[700],
                child: const Icon(Icons.zoom_out),
              ),
              const SizedBox(height: 10),
              _buildMapTypeDropdown(),
            ],
          ),
        ),
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

  // Build the Favorites View with scroll enabled
  Widget _buildFavoritesView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - 100, // Adjust height to fit screen
            child: _buildCoffeeListView(),
          ),
        ],
      ),
    );
  }

  // Build the Coffee List View for the "Favorites" tab
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
            _goToLocation(coffeePlace['position']); // Navigate to location on map when clicked
            _tabController.animateTo(0); // Switch back to map view
          },
        );
      },
    );
  }

  // Add a floating action button for adding new favorites
  Widget _buildAddFavoriteFAB() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'addFavorite',
        onPressed: () => _showAddFavoriteDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  // Show dialog to add a new favorite location
  void _showAddFavoriteDialog() {
    final _nameController = TextEditingController();
    final _addressController = TextEditingController();
    final _latController = TextEditingController();
    final _lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Favorite Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _lngController,
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
                final newPlace = {
                  'name': _nameController.text,
                  'address': _addressController.text,
                  'position': LatLng(
                    double.parse(_latController.text),
                    double.parse(_lngController.text),
                  ),
                };
                setState(() {
                  _coffeePlaces.add(newPlace);
                  _markers.add(
                    Marker(
                      markerId: MarkerId(newPlace['name'] as String),
                      position: newPlace['position'] as LatLng,
                      infoWindow: InfoWindow(
                        title: newPlace['name'] as String,
                        snippet: newPlace['address'] as String,
                      ),
                    ),
                  );
                });
                Navigator.pop(context);
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

  // Select a place and center it on the map
  Future<void> _selectPlace(Prediction prediction) async {
    final placeDetails = await places.getDetailsByPlaceId(prediction.placeId ?? '');
    final location = placeDetails.result.geometry?.location;
    if (location != null) {
      final LatLng selectedPosition = LatLng(location.lat, location.lng);
      _goToLocation(selectedPosition);

      setState(() {
        _searchResults = [];
        _markers.add(
          Marker(
            markerId: MarkerId(prediction.placeId ?? ''),
            position: selectedPosition,
            infoWindow: InfoWindow(title: prediction.description),
          ),
        );
      });
    }
  }

  // Add markers for the sample coffee places
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

  // Navigate to the selected coffee place on the map
  void _goToLocation(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 15.0));
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
