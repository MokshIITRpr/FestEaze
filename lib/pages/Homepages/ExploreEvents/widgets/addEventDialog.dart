import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fest_app/pages/Fests/festTemplatePage.dart';
import './csvImporter.dart'; // Import the new file

void showAddEventDialog(BuildContext context) {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController eventNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? errorMessage;
  String? selectedFileName; // Stores the CSV file name

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add Event"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Import from CSV Button

                // Show file name if selected
                if (selectedFileName != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    selectedFileName!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],

                // Hide manual input if file is selected
                if (selectedFileName == null) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: eventNameController,
                    decoration: const InputDecoration(
                      labelText: "Event Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _datePicker(context, "Start Dt.", startDate, DateTime.now(),
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
                      context, "End Dt.", endDate, startDate ?? DateTime.now(),
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
                ],
                ElevatedButton.icon(
                  onPressed: () async {
                    var csvData = await CsvImporter.importCsvFile();
                    if (csvData != null) {
                      setDialogState(() {
                        eventNameController.text = csvData["eventName"];
                        startDate = csvData["startDate"];
                        endDate = csvData["endDate"];
                        selectedFileName =
                            "Selected File: event_data.csv"; // Placeholder
                      });
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Import from CSV"),
                ),
                // Show error message
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
                  if (selectedFileName != null || // CSV selected
                      (eventNameController.text.isNotEmpty &&
                          startDate != null &&
                          endDate != null)) {
                    try {
                      // Store event in Firestore
                      DocumentReference docRef =
                          await _firestore.collection('fests').add({
                        'title': eventNameController.text,
                        'startDate': Timestamp.fromDate(startDate!),
                        'endDate': Timestamp.fromDate(endDate!),
                        'manager': [],
                        'pronite': [],
                        'subEvents': [],
                        'about': "Add text here ...",
                      });

                      print("Event added with ID: ${docRef.id}");

                      Navigator.of(context).pop(); // Close dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplatePage(
                            title: eventNameController.text,
                            docId: docRef.id,
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
      );
    },
  );
}

Widget _datePicker(BuildContext context, String label, DateTime? date,
    DateTime minDate, void Function(DateTime) onDatePicked) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        date == null
            ? "$label: Not Set"
            : "$label: ${DateFormat('dd/MM/yyyy').format(date)}",
        style: const TextStyle(fontSize: 16),
      ),
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
