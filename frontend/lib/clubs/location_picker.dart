import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationPicker extends StatefulWidget {
  final Function(LatLng) onLocationPicked;

  LocationPicker({required this.onLocationPicked});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng? _selectedLocation;
  CameraPosition? _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((location) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_selectedLocation != null) {
                widget.onLocationPicked(_selectedLocation!);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: _initialCameraPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
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
    );
  }
}