import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClgMap extends StatefulWidget {
  const ClgMap({super.key});

  @override
  _ClgMapState createState() => _ClgMapState();
}

class _ClgMapState extends State<ClgMap> {
  late GoogleMapController _mapController;

  // IIT Ropar Center Coordinates
  final LatLng _iitRoparCenter =
      LatLng(30.967570616980478, 76.47100921898688);

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

  // A map to hold the custom marker icons with labels
  final Map<String, BitmapDescriptor> _customMarkerIcons = {};

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerIcons();
  }

  Future<void> _loadCustomMarkerIcons() async {
    for (var entry in _importantPlaces.entries) {
      // Use the helper to choose the same color as your original pins.
      Color markerColor = _getMarkerColor(entry.key);
      BitmapDescriptor icon =
          await _createCustomMarkerBitmap(entry.key, markerColor);
      _customMarkerIcons[entry.key] = icon;
    }
    setState(() {});
  }

  // Returns the color for a given location name following your original logic.
  Color _getMarkerColor(String placeName) {
    if (placeName.contains("Main Gate")) {
      return Colors.red;
    } else if (placeName.contains("Cafeteria")) {
      return Colors.red;
    } else if (placeName.contains("Auditorium")) {
      return Colors.red;
    } else if (placeName.contains("Medical Center/Utility Block")) {
      return Colors.red;
    } else if (placeName.contains("Chenab Hostel")) {
      return Colors.green;
    } else if (placeName.contains("Sutlej Hostel")) {
      return Colors.green;
    } else if (placeName.contains("Beas Hostel")) {
      return Colors.green;
    } else if (placeName.contains("Ravi Hostel")) {
      return Colors.green;
    } else if (placeName.contains("Brahmaputra Hostel")) {
      return Colors.green;
    } else if (placeName.contains("Vollyball Court")) {
      return Colors.blue;
    } else if (placeName.contains("Basketball Court")) {
      return Colors.blue;
    } else if (placeName.contains("Lawn Tennis")) {
      return Colors.blue;
    } else if (placeName.contains("Athletics/Football Ground")) {
      return Colors.blue;
    } else if (placeName.contains("Cricket Ground")) {
      return Colors.blue;
    } else if (placeName.contains("Hockey Ground")) {
      return Colors.blue;
    } else if (placeName.contains("Lecture Hall Complex(LHC)")) {
      return Colors.orange;
    } else if (placeName.contains("Super Acadmic Building(SAB)")) {
      return Colors.orange;
    } else if (placeName.contains("S.Ramanujan Block(CSE)")) {
      return Colors.orange;
    } else if (placeName.contains("JC Bose Block(ECE)")) {
      return Colors.orange;
    } else if (placeName.contains("Satish Dhawan Block(Mech.)")) {
      return Colors.orange;
    } else if (placeName.contains("S.S.Bhatnagr Block(Chem.)")) {
      return Colors.orange;
    } else if (placeName.contains("Admin")) {
      return Colors.orange;
    } else if (placeName.contains("Library")) {
      return Colors.orange;
    } else {
      return Colors.purple;
    }
  }

  // Create a custom marker icon with a colored background and the text label.
  Future<BitmapDescriptor> _createCustomMarkerBitmap(
      String label, Color markerColor) async {
    final int width = 150;
    final int height = 60;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Draw a rounded rectangle with the provided marker color.
    final Paint paint = Paint()..color = markerColor;
    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Radius.circular(8),
    );
    canvas.drawRRect(rRect, paint);

    // Draw the label text centered in the rectangle.
    final TextSpan span = TextSpan(
      style: const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      text: label,
    );
    final TextPainter textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: width.toDouble());
    final double xCenter = (width - textPainter.width) / 2;
    final double yCenter = (height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(xCenter, yCenter));

    // Convert the canvas drawing to an image and then to a BitmapDescriptor.
    final ui.Image image =
        await recorder.endRecording().toImage(width, height);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // Create markers using the custom icons.
  Set<Marker> _createMarkers() {
    return _importantPlaces.entries.map((entry) {
      return Marker(
        markerId: MarkerId(entry.key),
        position: entry.value,
        icon: _customMarkerIcons[entry.key] ?? BitmapDescriptor.defaultMarker,
      );
    }).toSet();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IIT Ropar Campus Map",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 84, 91, 216),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _iitRoparCenter,
          zoom: 17.0,
        ),
        trafficEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _createMarkers(),
      ),
    );
  }
}
