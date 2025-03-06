import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClgMap extends StatefulWidget {
  const ClgMap({super.key});

  @override
  _ClgMapState createState() => _ClgMapState();
}

class _ClgMapState extends State<ClgMap> {
  late GoogleMapController mapController;

  final LatLng _collegeLocation = const LatLng(30.9754, 76.5274); // Change this to your college coordinates

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("College Map"),
        backgroundColor: const Color.fromARGB(255, 84, 91, 216),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _collegeLocation,
          zoom: 15.0, // Adjust zoom level as needed
        ),
        markers: {
          Marker(
            markerId: MarkerId("college_marker"),
            position: _collegeLocation,
            infoWindow: InfoWindow(
              title: "IIT Ropar",
              snippet: "This is the college location",
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        },
      ),
    );
  }
}
