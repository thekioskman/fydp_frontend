import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Add this import
import 'dart:async';

class LocationPicker extends StatefulWidget {
  final Function(LatLng, String) onLocationPicked; // Updated to include address

  LocationPicker({required this.onLocationPicked});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng? _selectedLocation;
  CameraPosition? _initialCameraPosition;
  String? _selectedAddress; // Store the human-readable address

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((location) {
      if(!mounted) return;
      setState(() {
        _initialCameraPosition = CameraPosition(
          target: location,
          zoom: 14.0,
        );
      });
    });
  }

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      // Use the geocoding package to get the address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          _selectedAddress = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        });
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              
              if (_selectedLocation != null) {
                // Fetch the address before returning
                await _getAddressFromLatLng(_selectedLocation!);
                if (!mounted) return;
                if (_selectedAddress != null) {
                  widget.onLocationPicked(_selectedLocation!, _selectedAddress!);
                }
              }
            },
          ),
        ],
      ),
      body: _initialCameraPosition == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _initialCameraPosition!,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                    onTap: (LatLng location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                    markers: _selectedLocation == null
                        ? {}
                        : {
                            Marker(
                              markerId: MarkerId('selected_location'),
                              position: _selectedLocation!,
                            ),
                          },
                  ),
                ),
                if (_selectedAddress != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Selected Address: $_selectedAddress',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
    );
  }
}