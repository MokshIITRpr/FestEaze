import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:fest_app/Pages/Homepages/PastEvents/z24.dart';

void showAddEventDialog(BuildContext context, Function(Event) addEvent) {
  TextEditingController eventNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

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
              _datePicker(context, "Start Date", startDate, (picked) {
                setDialogState(() => startDate = picked);
              }),
              _datePicker(context, "End Date", endDate, (picked) {
                setDialogState(() => endDate = picked);
              }),
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
                    navigateTo: Z24(),
                  ));
                  Navigator.of(context).pop();
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
    Function(DateTime) onDatePicked) {
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
            context: context, // Corrected: passing context
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
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
