import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:fest_app/Pages/festTemplatePage.dart';

void showAddEventDialog(BuildContext context, Function(Event) addEvent) {
  TextEditingController eventNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? errorMessage; // Persistent error message

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
                      endDate =
                          startDate; // Ensure endDate is at least startDate
                    }
                    errorMessage = null; // Clear error when valid
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
                    errorMessage = null; // Clear error if valid
                  } else {
                    errorMessage =
                        "End Date must be after or equal to Start Date";
                  }
                });
              }),
              if (errorMessage != null) // Show error message only when needed
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
              onPressed: () {
                if (eventNameController.text.isNotEmpty &&
                    startDate != null &&
                    endDate != null) {
                  addEvent(Event(
                    name: eventNameController.text,
                    date:
                        "${startDate!.toLocal().toString().split(' ')[0]} - ${endDate!.toLocal().toString().split(' ')[0]}",
                    colors: [
                      Colors.blueAccent.withOpacity(0.9),
                      Colors.lightBlue.withOpacity(0.7),
                    ],
                    navigateTo: TemplatePage(),
                  ));
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TemplatePage()), // Navigate to Z24
                  );
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
            firstDate: minDate, // Restrict selection to only future dates
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
