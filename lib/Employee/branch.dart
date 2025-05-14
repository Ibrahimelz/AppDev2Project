import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.locationTitle}) : super(key: key);

  final String locationTitle;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static final LatLng _location = LatLng(45.51444626, -73.6755719); // Your static location

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.locationTitle)),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _location,
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('my-location'),
            position: _location,
            infoWindow: const InfoWindow(title: "My Place"),
          ),
        },
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}
