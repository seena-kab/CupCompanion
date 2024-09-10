// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';


class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late DraggableScrollableController _draggableController;
  final Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;
   final String _selectedFilter = 'All'; // Default map type
  final List<MapType> _mapTypes = [
    MapType.normal,
    MapType.satellite,
    MapType.terrain,
    MapType.hybrid,
  ];
  final FocusNode _searchFocusNode = FocusNode();
  final double _listViewHeight = 200; // Default height, adjust as needed

  late GoogleMapController mapController;
  double zoomVal = 11.0;

  final TextEditingController _searchController = TextEditingController();

  final LatLng _center = const LatLng(45.521563, -122.677433);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  @override
  void initState() {
    super.initState();
    _draggableController = DraggableScrollableController();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _draggableController.animateTo(
          0.6,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        // UI updates can go here
      });
    }
  }

  @override
  void dispose() {
    _draggableController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _checkLocationPermission();
  }

  Future<LatLng?> geocodeAddress(String address) async {
    String googleApiKey = dotenv.env['GoogleMapsAPIKey'] ?? 'default_api_key';
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['results'].length > 0) {
          final lat = jsonResponse['results'][0]['geometry']['location']['lat'];
          final lng = jsonResponse['results'][0]['geometry']['location']['lng'];
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      print('Error occurred while geocoding: $e');
    }
    return null;
  }

  void _checkLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _updateLocationAndCamera();
  }

  Future<void> _updateLocationAndCamera() async {
    _locationData = await location.getLocation();
    if (_locationData.latitude != null && _locationData.longitude != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_locationData.latitude!, _locationData.longitude!),
            zoom: zoomVal,
          ),
        ),
      );
    } else {
      _showLocationErrorDialog();
    }
  }

  void _showLocationErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Error"),
          content: Text("Unable to fetch location data."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomBox(int index) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Box Title $index',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('More information here...'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                _draggableController.reset();
              },
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: zoomVal,
                ),
                mapType: _currentMapType,
                markers: _markers,
                onTap: _onMapTap,
              ),
            ),
            DraggableScrollableSheet(
              controller: _draggableController,
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.6,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _draggableController.animateTo(
                            0.6,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                          _searchFocusNode.requestFocus();
                        },
                        child: _buildSearchBar(),
                      ),
                      Expanded(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: 10,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildCustomBox(index);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              top: 50,
              right: 10,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () => _zoomIn(),
                    backgroundColor: Colors.orange[700],
                    child: Icon(Icons.zoom_in),
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: () => _zoomOut(),
                    backgroundColor: Colors.orange[700],
                    child: Icon(Icons.zoom_out),
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: _showMapTypeSelection,
                    backgroundColor: Colors.orange[700],
                    child: Icon(Icons.layers),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      endDrawer: _buildFilterDrawer(),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  void _zoomIn() {
    zoomVal++;
    mapController.animateCamera(
      CameraUpdate.zoomTo(zoomVal),
    );
  }

  void _zoomOut() {
    zoomVal--;
    mapController.animateCamera(
      CameraUpdate.zoomTo(zoomVal),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: TypeAheadField<String>(
                controller: _searchController,
                focusNode: _searchFocusNode,
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSelected: (String suggestion) {
                  _searchController.text = suggestion;
                  _searchAndNavigate(suggestion);
                },
                suggestionsCallback: (pattern) async {
                  if (pattern.isNotEmpty) {
                    return await _authService.fetchSuggestions(
                        pattern, sessionToken);
                  }
                  return [];
                },
              ),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
    );
  }

  void _searchAndNavigate(String address) {
    if (address.isNotEmpty) {
      _searchPlace(address);
      FocusScope.of(context).requestFocus(FocusNode());
      _draggableController.reset();
    }
  }

  void _showMapTypeSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Map Filters'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _mapTypes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_mapTypeToString(_mapTypes[index])),
                  onTap: () {
                    setState(() {
                      _currentMapType = _mapTypes[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _mapTypeToString(MapType mapType) {
    switch (mapType) {
      case MapType.normal:
        return 'Normal';
      case MapType.satellite:
        return 'Satellite';
      case MapType.terrain:
        return 'Terrain';
      case MapType.hybrid:
        return 'Hybrid';
      default:
        return 'Unknown';
    }
  }
//not finished yet
Future<void> pickAndProcessCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
        String? filePath = result.files.single.path;
          final input = File(filePath!).openRead();
          final fields = await input
              .transform(utf8.decoder)
              .transform(CsvToListConverter())
              .toList();

          // Adding a loading dialog
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                  return Center(child: CircularProgressIndicator());
              },
          );

          for (var row in fields) {
              if (row.isEmpty || row[10] == null) {  // Assuming address data starts at index 10
                  print('Empty or invalid row: $row');
                  continue;
              }

              // Extracting the address components based on the structure of your CSV
              String streetAddress = row[10];
              String city = row[12];
              String state = row[13];
              String zip = row[14];
              String businessType = row[5];  // Assuming business type is in the last column

              // Combine them into a full address
              String address = '$streetAddress, $city, $state, $zip';
              LatLng? coordinates = await geocodeAddress(address);

              if (coordinates != null) {
                  setState(() {
                      _addColoredMarker(coordinates, address, businessType);
                  });
              }

              // Optionally throttle the requests
              await Future.delayed(Duration(milliseconds: 200));
          }

          // Dismiss the loading dialog
          Navigator.of(context).pop();
          }
}

void _addColoredMarker(LatLng position, String markerId, String businessType) {
    BitmapDescriptor markerColor;

    //
    if (businessType.contains('HVAC')) {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    } else if (businessType.contains('Automation')) {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else if (businessType.contains('Chiller')) {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
    } else {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
    }

    setState(() {
        _markers.add(
            Marker(
                markerId: MarkerId(markerId),
                position: position,
                icon: markerColor,
                infoWindow: InfoWindow(title: markerId, snippet: businessType),
                onTap: () {
                    _showMarkerDialog(markerId, position);
                },
            ),
        );
    });
}


  void _addMarker(LatLng position, String markerId) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: markerId, snippet: "Geocoded Address"),
          onTap: () {
            _showMarkerDialog(markerId, position);
          },
        ),
      );
    });
  }

  Future<void> _showUploadCsvDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload CSV File'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Select a CSV file to create a map.'),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    pickAndProcessCsvFile();
                  },
                  icon: Icon(Icons.file_upload),
                  label: Text('Upload CSV'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterDrawer() {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          AppBar(
            leading: BackButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              'MENU',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text(
              'Create Map',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              _showUploadCsvDialog();
            },
          ),
          ListTile(
            title: Text(
              'My Maps',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              'Help',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _searchPlace(String address) async {
    LatLng? coordinates = await geocodeAddress(address);
    if (coordinates != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(
          coordinates,
        ),
      );
      _addMarker(coordinates, address);
    }
  }

  void _showMarkerDialog(String markerId, LatLng position) {
    String? selectedFilePath;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(markerId),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                      );
                      if (result != null) {
                        setState(() {
                          selectedFilePath = result.files.single.path;
                        });
                      }
                    },
                    child: Text("Pick a file"),
                  ),
                  if (selectedFilePath != null) 
                    Text('Selected file: ${selectedFilePath!.split('/').last}'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Save"),
                  onPressed: () {
                    if (selectedFilePath != null) {
                      setState(() {
                        _markers.removeWhere((m) => m.markerId.value == markerId);
                        _markers.add(
                          Marker(
                            markerId: MarkerId(markerId),
                            position: position,
                            infoWindow: InfoWindow(
                              title: markerId,
                              snippet: selectedFilePath!.split('/').last,
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                          ),
                        );
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onMapTap(LatLng position) {
    _showAddTextBoxDialog(position);
  }

  void _showAddTextBoxDialog(LatLng position) {
    TextEditingController textController = TextEditingController();
    String? selectedFilePath;
    bool addTextBox = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Add Marker"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text("Add Text Box"),
                    value: addTextBox,
                    onChanged: (bool? value) {
                      setState(() {
                        addTextBox = value ?? false;
                      });
                    },
                  ),
                  if (addTextBox)
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(hintText: "Enter text"),
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                      );
                      if (result != null) {
                        setState(() {
                          selectedFilePath = result.files.single.path;
                        });
                      }
                    },
                    child: Text("Pick a file"),
                  ),
                  if (selectedFilePath != null) 
                    Text('Selected file: ${selectedFilePath!.split('/').last}'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Add"),
                  onPressed: () {
                    if (textController.text.isNotEmpty || selectedFilePath != null || !addTextBox) {
                      setState(() {
                        _markers.add(
                          Marker(
                            markerId: MarkerId(position.toString()),
                            position: position,
                            infoWindow: InfoWindow(
                              title: textController.text.isNotEmpty ? textController.text : 'File',
                              snippet: selectedFilePath != null
                                  ? selectedFilePath!.split('/').last
                                  : 'Custom Marker',
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Marker color set to green
                          ),
                        );
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
