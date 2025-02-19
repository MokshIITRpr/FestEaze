import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fest_app/pages/Fests/festTemplatePage.dart';

void showAddEventDialog(BuildContext context) {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController eventNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? errorMessage;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text("Add Event"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventNameController,
                decoration: const InputDecoration(
                  labelText: "Event Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              _datePicker(context, "Start Date", startDate, DateTime.now(),
                  (picked) {
                setDialogState(() {
                  if (picked.isBefore(DateTime.now())) {
                    errorMessage = "Start Date must be after today";
                  } else {
                    startDate = picked;
                    if (endDate != null && endDate!.isBefore(startDate!)) {
                      endDate = startDate;
                    }
                    errorMessage = null;
                  }
                });
              }),
              _datePicker(
                  context, "End Date", endDate, startDate ?? DateTime.now(),
                  (picked) {
                setDialogState(() {
                  if (startDate == null ||
                      picked.isAfter(startDate!) ||
                      picked.isAtSameMomentAs(startDate!)) {
                    endDate = picked;
                    errorMessage = null;
                  } else {
                    errorMessage =
                        "End Date must be after or equal to Start Date";
                  }
                });
              }),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                if (eventNameController.text.isNotEmpty &&
                    startDate != null &&
                    endDate != null) {
                  try {
                    // Store event in Firestore
                    DocumentReference docRef =
                        await _firestore.collection('fests').add({
                      'title': eventNameController.text,
                      'startDate': Timestamp.fromDate(startDate!),
                      'endDate': Timestamp.fromDate(endDate!),
                      'pronite': [],
                      'subEvents': [],
                      'about':
                          "Add text here ...", // Fixed: Should be a string, not a list
                    });

                    print("Event added with ID: ${docRef.id}");

                    Navigator.of(context).pop(); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TemplatePage(
                          title: eventNameController.text,
                          docId: docRef.id, // Pass docId
                        ),
                      ),
                    );
                  } catch (e) {
                    print("Error adding event: $e");
                  }
                }
              },
            ),
          ],
        );
      },
    ),
  );
}

Widget _datePicker(BuildContext context, String label, DateTime? date,
    DateTime minDate, Function(DateTime) onDatePicked) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
          date == null
              ? "$label: Not Set"
              : "$label: ${date.toLocal().toString().split(' ')[0]}",
          style: const TextStyle(fontSize: 16)),
      TextButton(
        child: const Text("Select"),
        onPressed: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: minDate,
            firstDate: minDate,
            lastDate: DateTime(2030),
          );
          if (picked != null) {
            onDatePicked(picked);
          }
        },
      ),
    ],
  );
}
