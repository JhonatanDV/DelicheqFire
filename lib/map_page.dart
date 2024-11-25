import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LocationData? _currentLocation;
  final Location _locationService = Location();
  List<LatLng> _additionalPoints = [];
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getLocation();
  }

  Future<void> _getLocation() async {
    final hasPermission = await _locationService.hasPermission();
    if (hasPermission == PermissionStatus.denied) {
      await _locationService.requestPermission();
    }
    final locationData = await _locationService.getLocation();
    setState(() {
      _currentLocation = locationData;
    });

    _locationService.onLocationChanged.listen((LocationData result) {
      setState(() {
        _currentLocation = result;
      });
    });
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ubicación Actual"),
          content: Text(
            "Latitud: ${_currentLocation!.latitude}\n"
            "Longitud: ${_currentLocation!.longitude}",
          ),
          actions: [
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _generateAdditionalPoints() {
    if (_currentLocation != null) {
      setState(() {
        _additionalPoints = [
          LatLng(_currentLocation!.latitude! + 0.01, _currentLocation!.longitude!), // North
          LatLng(_currentLocation!.latitude! - 0.01, _currentLocation!.longitude!), // South
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude! + 0.01), // East
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude! - 0.01), // West
          LatLng(_currentLocation!.latitude! + 0.01, _currentLocation!.longitude! + 0.01), // NE
          LatLng(_currentLocation!.latitude! - 0.01, _currentLocation!.longitude! - 0.01), // SW
        ];
      });
    }
  }

  void _addCustomLocation() {
    final double? lat = double.tryParse(_latController.text);
    final double? lng = double.tryParse(_lngController.text);
    
    if (lat != null && lng != null) {
      setState(() {
        _additionalPoints = [LatLng(lat, lng)];
        _mapController.move(LatLng(lat, lng), 13.0);
        _currentLocation = LocationData.fromMap({'latitude': lat, 'longitude': lng});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map OpenStreetMap')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitud',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitud',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addCustomLocation,
                ),
              ],
            ),
          ),
          Expanded(
            child: _currentLocation == null                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      // Cambiado 'center' a 'initialCenter'
                      initialCenter: LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                     MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: LatLng(
                              _currentLocation!.latitude!,
                              _currentLocation!.longitude!,
                            ),
                            // Usar 'child' en lugar de 'builder'
                            child: GestureDetector(
                              onTap: () {
                                _showLocationDialog();
                              },
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ),
                          ..._additionalPoints.map((point) => Marker(
                                width: 80.0,
                                height: 80.0,
                                point: point,
                                // Usar 'child' en lugar de 'builder'
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await _getLocation();
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _generateAdditionalPoints,
            child: const Icon(Icons.add_location_alt),
          ),
        ],
      ),
    );
  }
}