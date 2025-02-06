import 'package:flutter/material.dart';

class Clgmap extends StatefulWidget {
  const Clgmap({super.key});

  @override
  _ClgmapState createState() => _ClgmapState();
}

class _ClgmapState extends State<Clgmap> {
  TransformationController _controller = TransformationController();
  bool _isZoomed = false;

  void _resetZoom() {
    setState(() {
      _controller.value = Matrix4.identity();
      _isZoomed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("College Map", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade500],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content below the AppBar
          Column(
            children: [
              // Instruction text, just below the AppBar
              SizedBox(height: 70), // Adjust this height for better spacing
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "📌 Pinch to zoom & drag to move",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  transformationController: _controller,
                  panEnabled: true,
                  minScale: 1.0,
                  maxScale: 4.0,
                  onInteractionEnd: (details) {
                    setState(() {
                      _isZoomed = true;
                    });
                  },
                  child: Center(
                    child: Image.asset(
                      'assets/campus_map.jpg',
                      fit: BoxFit.contain, // Ensures full image is visible
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // Reset Zoom Button (only shows if zoomed)
      floatingActionButton: _isZoomed
          ? FloatingActionButton(
              onPressed: _resetZoom,
              backgroundColor: Colors.white,
              child: Icon(Icons.zoom_out_map, color: Colors.deepPurple),
            )
          : null,
    );
  }
}
