import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/autoImageSlider.dart';
import './widgets/textFieldSection.dart';
import './utils/database.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fest_app/data.dart';
import 'package:fest_app/pages/Events/eventTemplatePage.dart';
import 'package:fest_app/snackbar.dart';

class TemplatePage extends StatefulWidget {
  final String title;
  final String docId; // Accept docId

  const TemplatePage({super.key, required this.title, required this.docId});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _proniteController = TextEditingController();
  final TextEditingController _subEventsController = TextEditingController();
  final TextEditingController _searchController =
      TextEditingController(); // Search controller
  final FocusNode _searchFocusNode = FocusNode(); // Added FocusNode for search
  bool isEditing = false;
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isAdmin = false;
  final _userdata = UserData();

  final List<String> _imagePaths = [
    'assets/aarohan.jpg',
    'assets/zeitgeist.jpeg',
    'assets/advitiya.jpeg',
    'assets/sponsor.jpeg',
  ];

  List<DocumentReference> proniteEvents = [];
  List<DocumentReference> subEventsList = [];
  List<DocumentReference> filteredEvents =
      []; // For filtered events based on search query
  List<String> favouriteEvents = [];
  List<String> observers = [];
  int _lastRequestId = 0;

  @override
  void initState() {
    super.initState();
    _fetchText();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('fests')
        .doc(widget.docId) // Use dynamic docId
        .get();

    if (docSnapshot.exists) {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _userdata.getUser();
        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          bool a1 = userData['admin'] ?? false;
          bool a2 = false;

          // Fetch favourites as List<DocumentReference>
          List<String>? tempFav = _userdata.getFavorites();
          List<String> favs = tempFav ?? [];
          try {
            a2 = docSnapshot['manager'].contains(userData['email']);
          } catch (e) {
            a2 = false;
          }
          setState(() {
            _isAdmin = (a1 || a2);
            favouriteEvents = favs;
          });
        }
      }
    }
  }

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
        filteredEvents = subEventsList; // Initial events list
      });
    }
  }

  // This function filters the events based on the search query.
  Future<void> _filterEvents(String rawQuery) async {
    final int requestId = ++_lastRequestId;
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredEvents = subEventsList; // If query is empty, show all events
      });
      return;
    }

    List<DocumentReference> filteredList = [];

    for (var eventRef in subEventsList) {
      if (requestId != _lastRequestId) return;
      var eventSnapshot = await eventRef.get();
      // Check if the document exists and its data is not null.
      if (!eventSnapshot.exists || eventSnapshot.data() == null) {
        continue;
      }
      var eventData = eventSnapshot.data() as Map<String, dynamic>;
      String eventName = (eventData['eventName'] ?? '').toLowerCase();
      if (eventName.contains(query)) {
        filteredList.add(eventRef);
      }
    }

    if (requestId != _lastRequestId) return;
    setState(() {
      filteredEvents = filteredList;
    });
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
    Map<String, dynamic> mp = {};
    DocumentReference newDocRef =
        FirebaseFirestore.instance.collection('fests').doc();
    showEventDialog(context, newDocRef, true, mp, field, widget.docId, setState,
        _fetchText);
  }

  void _updateEvent(DocumentReference eventRef, String field,
      Map<String, dynamic> eventData) {
    showEventDialog(context, eventRef, false, eventData, field, widget.docId,
        setState, _fetchText);
  }

  void toggleFavorite(DocumentReference eventRef, BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Use custom snackbar to prompt login.
      showCustomSnackBar(
        context,
        'Please log in to add favorites!',
        backgroundColor: Colors.redAccent,
        icon: Icons.error,
      );
      return;
    }

    if (favouriteEvents.contains(eventRef.id)) {
      favouriteEvents.remove(eventRef.id); // Remove from favorites.
    } else {
      favouriteEvents.add(eventRef.id); // Add to favorites.
    }

    setState(() {}); // Update UI.

    try {
      _userdata.updateWishlist(favouriteEvents);
    } catch (e) {
      // Use custom snackbar to display error.
      showCustomSnackBar(
        context,
        'Error updating favorites: $e',
        backgroundColor: Colors.redAccent,
        icon: Icons.error,
      );
    }
  }

  void _removeEvent(String field, DocumentReference eventRef) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Text("Are you sure you want to remove the event?"),
              ),
              actions: [
                TextButton(
                  child: Text("Yes"),
                  onPressed: () async {
                    try {
                      await _firestore
                          .collection('events')
                          .doc(eventRef.id)
                          .delete();
                      await _firestore
                          .collection('fests')
                          .doc(widget.docId)
                          .update({
                        field: FieldValue.arrayRemove([eventRef]),
                      });
                      showCustomSnackBar(context, "Event Deleted Successfully");
                    } catch (e) {
                      showCustomSnackBar(context, 'Error in deleting Event $e');
                    }
                    Navigator.pop(context);
                    _fetchText();
                  },
                ),
                TextButton(
                  child: Text("No"),
                  onPressed: () {
                    showCustomSnackBar(context, "Event Not Deleted");
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Improved search bar widget with dedicated FocusNode and clear button.
  Widget buildSearchBar() {
    return SizedBox(
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        focusNode: _searchFocusNode,
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          // With a fixed height, set vertical padding to zero or a minimal amount,
          // so that the text and cursor are centered without overflowing.
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.white),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    _searchController.clear();
                    _filterEvents('');
                    _searchFocusNode.unfocus();
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (query) {
          _filterEvents(query);
          setState(() {}); // Refresh UI for suffix icon.
        },
        onSubmitted: (value) {
          _searchFocusNode.unfocus();
        },
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
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            if (_isAdmin)
              IconButton(
                icon: const Icon(Icons.add,
                    color:
                        Color.fromRGBO(30, 215, 96, 1)), // Spotify Green color.
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

  Widget buildEventList(List<DocumentReference> eventList, String field) {
    return eventList.isNotEmpty
        ? SizedBox(
            height: 250, // Fixed height for square cards.
            child: ListView(
              scrollDirection: Axis.horizontal, // Horizontal scrolling.
              children: eventList.map((eventRef) {
                return FutureBuilder<DocumentSnapshot>(
                  future: eventRef.get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData && snapshot.data!.exists) {
                      var eventData =
                          snapshot.data!.data() as Map<String, dynamic>;

                      // Extract event details.
                      String eventName = eventData['eventName'] ?? 'No title';
                      String venue = eventData['venue'] ?? 'Unknown';
                      // Document ID.
                      String docId = eventRef.id;
                      String type = eventData['type'].trim() ?? 'None';
                      String imageType = (type == 'None'
                          ? 'assets/Default.jpg'
                          : 'assets/$type.jpeg');

                      // Handle Timestamp fields.
                      Timestamp timestampDate =
                          eventData['date'] ?? Timestamp.now();
                      Timestamp timestampStartTime =
                          eventData['startTime'] ?? Timestamp.now();
                      Timestamp timestampEndTime =
                          eventData['endTime'] ?? Timestamp.now();

                      DateTime date = timestampDate.toDate();
                      DateTime startTime = timestampStartTime.toDate();
                      DateTime endTime = timestampEndTime.toDate();

                      String formattedDate =
                          DateFormat('dd-MM-yyyy').format(date);
                      String formattedStartTime =
                          DateFormat('HH:mm').format(startTime);
                      String formattedEndTime =
                          DateFormat('HH:mm').format(endTime);

                      String timeRange =
                          '$formattedStartTime - $formattedEndTime';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventTemplatePage(
                                title: eventName,
                                isSuperAdmin: _isAdmin,
                                eventRef: eventRef,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 200, // Fixed width for square-shaped card.
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white, // Background color.
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _isAdmin
                                    ? Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage(imageType),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            // Edit icon on the top right.
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _updateEvent(eventRef,
                                                        field, eventData);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.green
                                                          .withOpacity(0.8),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: const Icon(
                                                      Icons.edit,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Remove icon on the top left.
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _removeEvent(
                                                        field, eventRef);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.black
                                                          .withOpacity(0.8),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.white70,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: Image.asset(
                                          imageType,
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.broken_image,
                                              size: 100,
                                              color: Colors.red,
                                            );
                                          },
                                        ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              eventName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => toggleFavorite(
                                                eventRef, context),
                                            child: Icon(
                                              favouriteEvents
                                                      .contains(eventRef.id)
                                                  ? Icons.star
                                                  : Icons.star_border_outlined,
                                              size: 20,
                                              color: favouriteEvents
                                                      .contains(eventRef.id)
                                                  ? const Color.fromARGB(
                                                      255, 236, 54, 54)
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 20, color: Colors.black),
                                          const SizedBox(width: 8),
                                          Text(' $formattedDate',
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              size: 20, color: Colors.black),
                                          const SizedBox(width: 8),
                                          Text(' $timeRange',
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 20, color: Colors.black),
                                          const SizedBox(width: 8),
                                          Text(' $venue',
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                );
              }).toList(),
            ),
          )
        : const Center(child: Text('No events available.'));
  }

  @override
  Widget build(BuildContext context) {
    // Wrap entire page with GestureDetector to dismiss focus when tapping outside.
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 84, 91, 216),
          title: Text(
            widget.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Padding(
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
                    isAdmin: _isAdmin,
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
                  buildEditableSection("Flagship Events", _proniteController,
                      'pronite', proniteEvents),
                  const SizedBox(height: 20),
                  buildEventList(proniteEvents, 'pronite'),
                  const SizedBox(height: 20),
                  buildEditableSection("Explore Club Events",
                      _subEventsController, 'subEvents', subEventsList),
                  const SizedBox(height: 20),
                  // Improved Search Bar.
                  buildSearchBar(),
                  const SizedBox(height: 20),
                  buildEventList(filteredEvents, 'subEvents'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
