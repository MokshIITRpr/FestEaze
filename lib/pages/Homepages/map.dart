import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClgMap extends StatefulWidget {
  const ClgMap({super.key});

  @override
  _ClgMapState createState() => _ClgMapState();
}

class _ClgMapState extends State<ClgMap> {
  late GoogleMapController mapController;

  // IIT Ropar Center Coordinates
  final LatLng _iitRoparCenter = LatLng(30.967570616980478, 76.47100921898688);

  // Important Buildings (Latitude, Longitude)
  final Map<String, LatLng> _importantPlaces = {
    "Main Gate": LatLng(30.971171010025753, 76.4731688242437),
    "Admin Block": LatLng(30.96885352124612, 76.47317616597945),
    "Library": LatLng(30.967208462813822, 76.47319179760098),
    "Chenab Hostel": LatLng(30.969085297135027, 76.46570286393116),
    "Sutlej Hostel": LatLng(30.96923919396277, 76.46842971819153),
    "Beas Hostel": LatLng(30.96926481836463, 76.46671590437404),
    "Ravi Hostel": LatLng(30.967418956095425, 76.46983082119206),
    "Brahmaputra Hostel": LatLng(30.966986576357574, 76.46676773847858),
    "Vollyball Court": LatLng(30.96326526975179, 76.47218043625986),
    "Basketball Court": LatLng(30.963274469699535, 76.47248084368039),
    "Lawn Tennis": LatLng(30.96292027107216, 76.47248620809863),
    "Athletics/Football Ground": LatLng(30.963141070369627, 76.47534007847555),
    "Cricket Ground": LatLng(30.96093765446312, 76.47547955337636),
    "Hockey Ground": LatLng(30.9616460651144, 76.47425110169115),
    "Cafeteria": LatLng(30.966296604618933, 76.4712738496136),
    "Medical Center/Utility Block": LatLng(30.967676179831212, 76.46973182528265),
    "Lecture Hall Complex(LHC)": LatLng(30.96794883769051, 76.4717164225722),
    "Auditorium": LatLng(30.967924779672767, 76.47303886394066),
    "Super Acadmic Building(SAB)": LatLng(30.967857417198633, 76.47442303170348),
    "S.Ramanujan Block(CSE)": LatLng(30.969045876748293, 76.4756912286391),
    "JC Bose Block(ECE)": LatLng(30.96878284514457, 76.4746905127549),
    "Satish Dhawan Block(Mech.)": LatLng(30.96884539540658, 76.47156678283248),
    "S.S.Bhatnagr Block(Chem.)": LatLng(30.969015403612165, 76.47060347687236),
  };

  Set<Marker> _createMarkers() {
    return _importantPlaces.entries.map((entry) {
      return Marker(
        markerId: MarkerId(entry.key),
        position: entry.value,
        infoWindow: InfoWindow(title: entry.key),
        icon: _getMarkerColor(entry.key), // Assign different colors
      );
    }).toSet();
  }

  BitmapDescriptor _getMarkerColor(String placeName) {
    if (placeName.contains("Main Gate")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed); // Hostel - Orange
    } else if (placeName.contains("Cafeteria")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed); // Library - Green
    } else if (placeName.contains("Auditorium")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed); // Sports - Red
    } else if (placeName.contains("Medical Center/Utility Block")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed); // Admin - Blue
    } else if (placeName.contains("Chenab Hostel")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); // Admin - Blue
    } else if (placeName.contains("Sutlej Hostel")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); // Admin - Blue
    } else if (placeName.contains("Beas Hostel")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); // Admin - Blue
    } else if (placeName.contains("Ravi Hostel")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); // Admin - Blue
    } else if (placeName.contains("Brahmaputra Hostel")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); // Admin - Blue
    } else if (placeName.contains("Vollyball Court")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue); // Admin - Blue
    } else if (placeName.contains("Basketball Court")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue); // Admin - Blue
    } else if (placeName.contains("Lawn Tennis")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue); // Admin - Blue
    } else if (placeName.contains("Athletics/Football Ground")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue); // Admin - Blue
    } else if (placeName.contains("Cricket Ground")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue); // Admin - Blue
    } else if (placeName.contains("Hockey Ground")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue); // Admin - Blue
    } else if (placeName.contains("Lecture Hall Complex(LHC)")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange); // Admin - Blue
    } else if (placeName.contains("Super Acadmic Building(SAB)")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange); // Admin - Blue
    } else if (placeName.contains("S.Ramanujan Block(CSE)")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange); // Admin - Blue
    } else if (placeName.contains("JC Bose Block(ECE)")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange); // Admin - Blue
    } else if (placeName.contains("Satish Dhawan Block(Mech.)")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange); // Admin - Blue
    } else if (placeName.contains("S.S.Bhatnagr Block(Chem.)")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange); // Admin - Blue
    } else if (placeName.contains("Admin")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange); // Admin - Blue
    } else if (placeName.contains("Library")) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange); // Admin - Blue
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet); // Default - Violet
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IIT Ropar Campus Map", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 84, 91, 216),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _iitRoparCenter,
          zoom: 17.0, // Adjust zoom for better road visibility
        ),
        //mapType: MapType.hybrid, // Hybrid for better road visibility
        trafficEnabled: true, // Highlights road traffic
        myLocationEnabled: true, // User location button
        myLocationButtonEnabled: true,
        markers: _createMarkers(),
      ),
    );
  }
}
