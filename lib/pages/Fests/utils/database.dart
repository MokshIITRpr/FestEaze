import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> fetchDataFromFirestore({
  required String docId,
  required TextEditingController aboutController,
  required TextEditingController proniteController,
  required TextEditingController subEventsController,
  required List<DocumentReference> proniteEvents,
  required List<DocumentReference> subEventsList,
  required Function setStateCallback,
}) async {
  var doc =
      await FirebaseFirestore.instance.collection('fests').doc(docId).get();

  if (doc.exists) {
    setStateCallback(() {
      aboutController.text = doc['about'] ?? "Hardcoded random text";
      proniteController.text = doc['pronite'] ?? "Hardcoded random text";
      subEventsController.text = doc['subEvents'] ?? "Hardcoded random text";

      // Clear existing lists before adding new data
      proniteEvents.clear();
      subEventsList.clear();

      if (doc['pronite'] != null && doc['pronite'] is List) {
        proniteEvents.addAll(
            (doc['pronite'] as List).map((e) => e as DocumentReference));
      }

      if (doc['subEvents'] != null && doc['subEvents'] is List) {
        subEventsList.addAll(
            (doc['subEvents'] as List).map((e) => e as DocumentReference));
      }
    });
  } else {
    setStateCallback(() {
      aboutController.text = "Hardcoded random text";
      proniteController.text = "Hardcoded random text";
      subEventsController.text = "Hardcoded random text";
      proniteEvents.clear();
      subEventsList.clear();
    });
  }
}

Future<void> updateDataInFirestore({
  required String docId,
  required String field,
  required String text,
}) async {
  await FirebaseFirestore.instance.collection('fests').doc(docId).update({
    field: text,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

void showEventDialog(
  BuildContext context,
  String field,
  String docId,
  Function setStateCallback,
  List<DocumentReference> proniteEvents,
  List<DocumentReference> subEventsList,
  Function _fetchText,
) {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController datetimeController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Add Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title")),
            TextField(
                controller: venueController,
                decoration: const InputDecoration(labelText: "Venue")),
            TextField(
                controller: datetimeController,
                decoration: const InputDecoration(labelText: "Date & Time")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              var newEvent =
                  await FirebaseFirestore.instance.collection('events').add({
                'title': titleController.text,
                'venue': venueController.text,
                'datetime': datetimeController.text,
                'parentFest':
                    FirebaseFirestore.instance.collection('fests').doc(docId),
              });

              await FirebaseFirestore.instance
                  .collection('fests')
                  .doc(docId)
                  .update({
                field: FieldValue.arrayUnion([newEvent]),
              });

              Navigator.pop(context); // Close the dialog
              _fetchText();
            },
            child: const Text("Add Event"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}
