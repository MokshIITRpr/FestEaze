import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fest_app/pages/Fests/festTemplatePage.dart';
import './csvImporter.dart';
import '../utils/databaseHandler.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

void showAddEventDialog(BuildContext context) {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHandler _dbHandler = DatabaseHandler();

  TextEditingController eventNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? errorMessage;
  String? selectedFileName; // Stores the CSV file name
  String? about;
  Map<String, dynamic>? csvData; // Store CSV Data for passing

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add Event"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show selected file name
                  if (selectedFileName != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Selected file: $selectedFileName",
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
                          if (endDate != null &&
                              endDate!.isBefore(startDate!)) {
                            endDate = startDate;
                          }
                          errorMessage = null;
                        }
                      });
                    }),
                    _datePicker(context, "End Dt.", endDate,
                        startDate ?? DateTime.now(), (picked) {
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
                      var importedData = await CsvImporter.importCsvFile();
                      if (importedData != null) {
                        setDialogState(() {
                          csvData = importedData; // Store CSV Data for later
                          selectedFileName = importedData["fileName"];

                          // ✅ Parse and store CSV values
                          eventNameController.text = importedData["eventName"];
                          startDate = importedData[
                              "startDate"]; // Fix string to DateTime
                          endDate =
                              importedData["endDate"]; // Fix string to DateTime
                          about = importedData["about"];
                        });
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Import from CSV"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Load PDF bytes from assets
                      final pdfBytes =
                          await rootBundle.load('assets/template.pdf');

                      // Get temporary directory to store the file
                      final tempDir = await getTemporaryDirectory();
                      final file = File('${tempDir.path}/template.pdf');

                      // Write bytes to file
                      await file.writeAsBytes(pdfBytes.buffer.asUint8List());

                      // Open the file using default PDF viewer
                      await OpenFile.open(file.path);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Open PDF Template"),
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
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text("Save"),
                onPressed: () async {
                  if (selectedFileName != null) {
                    // ✅ CSV Import Mode
                    try {
                      DocumentReference festRef =
                          await _dbHandler.addFestWithEvents(csvData!);

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => TemplatePage(
                              title: eventNameController.text,
                              docId: festRef.id), // 🔥 Navigate to details page
                        ),
                      );
                    } catch (e) {
                      print("❌ Error adding event from CSV: $e");
                    }
                  } else if (eventNameController.text.isNotEmpty &&
                      startDate != null &&
                      endDate != null) {
                    // ✅ Manual Entry Mode
                    try {
                      DocumentReference docRef =
                          await _firestore.collection('fests').add({
                        'title': eventNameController.text,
                        'startDate': Timestamp.fromDate(startDate!),
                        'endDate': Timestamp.fromDate(endDate!),
                        'manager': [],
                        'pronite': [],
                        'subEvents': [],
                        'about': about,
                        'createdAt': Timestamp.now(),
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
                      print("❌ Error adding event: $e");
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
