import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  final PageController _pageController = PageController();
  String docId = "uCZlvtZBNcq2IMtXN7ld";
  final TextEditingController _controller = TextEditingController();
  bool isEditing = false;

  int _currentIndex = 0;

  final List<String> _imagePaths = [
    'assets/test_img1.jpg',
    'assets/test_img2.jpg',
    'assets/test_img3.jpeg',
    'assets/test_img4.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _autoSlideImages();
    _fetchText();
  }

  void _autoSlideImages() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _imagePaths.length;
          _pageController.animateToPage(
            _currentIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
        _autoSlideImages();
      }
    });
  }

  Future<void> _fetchText() async {
    var doc = await FirebaseFirestore.instance
        .collection('festTempText')
        .doc(docId)
        .get();
    if (doc.exists) {
      setState(() {
        _controller.text = doc['content'];
      });
    } else {
      _controller.text =
          "Hardcoded random text"; // Default if no Firestore data
    }
  }

  Future<void> updateText() async {
    await FirebaseFirestore.instance
        .collection('festTempText')
        .doc(docId)
        .update({
      'content': _controller.text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zeitgeist 2024',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Image slider with auto-play
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _imagePaths.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          _imagePaths[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "About",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    enabled: isEditing,
                    maxLines: null,
                    style: TextStyle(
                      color: Colors.black, 
                      fontSize: 16
                    ), 
                    decoration: InputDecoration(
                      border: InputBorder.none, 
                    ),
                  ),
                  IconButton(
                    icon: Icon(isEditing ? Icons.check : Icons.edit,
                        color: Colors.deepPurpleAccent),
                    onPressed: () {
                      if (isEditing) {
                        updateText(); // Save to Firestore
                      }
                      setState(() {
                        isEditing = !isEditing; // Toggle edit mode
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Sub Events",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    enabled: isEditing,
                    maxLines: null,
                    style: TextStyle(
                      color: Colors.black, 
                      fontSize: 16
                    ), 
                    decoration: InputDecoration(
                      border: InputBorder.none, 
                    ),
                  ),
                  IconButton(
                    icon: Icon(isEditing ? Icons.check : Icons.edit,
                        color: Colors.deepPurpleAccent),
                    onPressed: () {
                      if (isEditing) {
                        updateText(); // Save to Firestore
                      }
                      setState(() {
                        isEditing = !isEditing; // Toggle edit mode
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Pronite",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    enabled: isEditing,
                    maxLines: null,
                    style: TextStyle(
                      color: Colors.black, 
                      fontSize: 16
                    ), 
                    decoration: InputDecoration(
                      border: InputBorder.none, 
                    ),
                  ),
                  IconButton(
                    icon: Icon(isEditing ? Icons.check : Icons.edit,
                        color: Colors.deepPurpleAccent),
                    onPressed: () {
                      if (isEditing) {
                        updateText(); 
                      }
                      setState(() {
                        isEditing = !isEditing; 
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

