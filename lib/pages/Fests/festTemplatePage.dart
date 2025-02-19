import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/autoImageSlider.dart';
import './widgets/textFieldSection.dart';
import './utils/database.dart';

class TemplatePage extends StatefulWidget {
  final String title;
  final String docId; // Accept docId

  const TemplatePage({super.key, required this.title, required this.docId});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  final PageController _pageController = PageController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _proniteController = TextEditingController();
  final TextEditingController _subEventsController = TextEditingController();
  bool isEditing = false;
  int _currentIndex = 0;

  final List<String> _imagePaths = [
    'assets/test_img1.jpg',
    'assets/test_img2.jpg',
    'assets/test_img3.jpeg',
    'assets/test_img4.jpeg',
  ];

  List<DocumentReference> proniteEvents = [];
  List<DocumentReference> subEventsList = [];

  @override
  void initState() {
    super.initState();
    // _autoSlideImages();
    _fetchText();
  }

  // void _autoSlideImages() {
  //   Future.delayed(const Duration(seconds: 3), () {
  //     if (mounted) {
  //       setState(() {
  //         _currentIndex = (_currentIndex + 1) % _imagePaths.length;
  //         _pageController.animateToPage(
  //           _currentIndex,
  //           duration: const Duration(milliseconds: 500),
  //           curve: Curves.easeInOut,
  //         );
  //       });
  //     }
  //     _autoSlideImages();
  //   });
  // }

  Future<void> _fetchText() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('fests')
        .doc(widget.docId) // Use dynamic docId
        .get();

    if (docSnapshot.exists) {
      setState(() {
        _aboutController.text = docSnapshot['about'] ?? '';
        proniteEvents =
            List<DocumentReference>.from(docSnapshot['pronite'] ?? []);
        subEventsList =
            List<DocumentReference>.from(docSnapshot['subEvents'] ?? []);
      });
    }
  }

  Future<void> updateText(String field, String text) async {
    await updateDataInFirestore(
      docId: widget.docId, // Use dynamic docId
      field: field,
      text: text,
    );
    setState(() {
      isEditing = false;
    });
  }

  void _addEvent(String field) {
    showEventDialog(context, field, widget.docId, setState, proniteEvents,
        subEventsList, _fetchText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoImageSlider(imagePaths: _imagePaths),
              const SizedBox(height: 20),
              TextFieldSection(
                title: "About",
                controller: _aboutController,
                isEditing: isEditing,
                onEdit: () {
                  if (isEditing) {
                    updateText('about', _aboutController.text);
                  }
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
              ),
              const SizedBox(height: 20),
              buildEditableSection(
                  "Pronite", _proniteController, 'pronite', proniteEvents),
              buildEventList(proniteEvents),
              const SizedBox(height: 20),
              buildEditableSection("Sub Events", _subEventsController,
                  'subEvents', subEventsList),
              buildEventList(subEventsList),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditableSection(String title, TextEditingController controller,
      String field, List<DocumentReference> eventList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue),
              onPressed: () {
                if (isEditing) {
                  updateText(field, controller.text);
                }
                _addEvent(field);
              },
            )
          ],
        ),
      ],
    );
  }

  Widget buildEventList(List<DocumentReference> eventList) {
    return eventList.isNotEmpty
        ? Column(
            children: eventList
                .map((eventRef) => FutureBuilder<DocumentSnapshot>(
                      future: eventRef.get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasData && snapshot.data!.exists) {
                          var eventData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(eventData['title'] ?? 'No title',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  'Venue: ${eventData['venue'] ?? 'Unknown'}\nDate: ${eventData['datetime'] ?? 'Unknown'}'),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ))
                .toList(),
          )
        : const SizedBox();
  }
}
