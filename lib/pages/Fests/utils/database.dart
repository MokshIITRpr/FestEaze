import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fest_app/snackbar.dart';

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
  DocumentReference eventRef,
  bool add,
  Map<String, dynamic> eventData,
  String field,
  String docId,
  Function setStateCallback,
  Function _fetchText,
) {
  final TextEditingController titleController =
      TextEditingController(text: add ? "" : eventData['eventName']);
  final TextEditingController venueController =
      TextEditingController(text: add ? "" : eventData['venue']);
  final List<String> eventChoices = [
    'Default',
    'DJ Night',
    'Star Night',
    'Coding',
    'Software',
    'Robotics',
    'Dance',
    'Basketball',
    'Volleyball',
    'Cricket',
    'Soccer',
    'Music',
    'Sports',
    'Athletics'
  ];
  String? selectedEvent;
  DateTime? eventDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? errorMessage;

  if (!add) {
    if (eventData['type'] != null) selectedEvent = eventData['type'];
    if (eventData['date'] != null) eventDate = eventData['date'].toDate();
    if (eventData['startTime'] != null) {
      startTime = TimeOfDay.fromDateTime(eventData['startTime'].toDate());
    }
    if (eventData['endTime'] != null) {
      endTime = TimeOfDay.fromDateTime(eventData['endTime'].toDate());
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: add ? Text("Add Event") : Text("Update Event"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Event Name"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: venueController,
                    decoration: const InputDecoration(labelText: "Venue"),
                  ),
                  const SizedBox(height: 10),
                  _eventPicker(
                      context, "Event Type", selectedEvent, eventChoices,
                      (picked) {
                    setDialogState(() {
                      if (picked.isEmpty) {
                        errorMessage = "Please pick an Event Type";
                      } else {
                        selectedEvent = picked;
                        errorMessage = null;
                      }
                    });
                  }),
                  const SizedBox(height: 10),

                  // Date Picker (allows today)
                  _datePicker(context, "Date", eventDate, DateTime.now(),
                      (picked) {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);

                    setDialogState(() {
                      if (picked.isBefore(today)) {
                        errorMessage = "Date must be today or later";
                      } else {
                        eventDate = picked;
                        errorMessage = null;
                      }
                    });
                  }),

                  const SizedBox(height: 10),

                  // Start Time Picker
                  _timePicker(context, "Start Time", startTime, (picked) {
                    setDialogState(() {
                      startTime = picked;
                      if (endTime != null &&
                          (picked.hour > endTime!.hour ||
                              (picked.hour == endTime!.hour &&
                                  picked.minute > endTime!.minute))) {
                        errorMessage = "Start time must be before end time";
                      } else {
                        errorMessage = null;
                      }
                    });
                  }),

                  const SizedBox(height: 10),

                  // End Time Picker
                  _timePicker(context, "End Time", endTime, (picked) {
                    setDialogState(() {
                      if (startTime == null ||
                          picked.hour > startTime!.hour ||
                          (picked.hour == startTime!.hour &&
                              picked.minute > startTime!.minute)) {
                        endTime = picked;
                        errorMessage = null;
                      } else {
                        errorMessage = "End time must be after start time";
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
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      venueController.text.isNotEmpty &&
                      eventDate != null &&
                      startTime != null &&
                      endTime != null) {
                    try {
                      // Combine date and time into DateTime objects
                      DateTime startDateTime = DateTime(
                        eventDate!.year,
                        eventDate!.month,
                        eventDate!.day,
                        startTime!.hour,
                        startTime!.minute,
                      );

                      DateTime endDateTime = DateTime(
                        eventDate!.year,
                        eventDate!.month,
                        eventDate!.day,
                        endTime!.hour,
                        endTime!.minute,
                      );

                      if (add) {
                        // Add event to Firestore in 'events' collection
                        DocumentReference newEvent = await FirebaseFirestore
                            .instance
                            .collection('events')
                            .add({
                          'eventName': titleController.text,
                          'venue': venueController.text,
                          'type': selectedEvent,
                          'date': Timestamp.fromDate(eventDate!),
                          'startTime': Timestamp.fromDate(startDateTime),
                          'endTime': Timestamp.fromDate(endDateTime),
                          'parentFest': FirebaseFirestore.instance
                              .collection('fests')
                              .doc(docId),
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        // Link event in parent fest document
                        await FirebaseFirestore.instance
                            .collection('fests')
                            .doc(docId)
                            .update({
                          field: FieldValue.arrayUnion([newEvent]),
                        });
                        showCustomSnackBar(
                            context, "Event Added Successfully!");
                      } else {
                        await FirebaseFirestore.instance
                            .collection('events')
                            .doc(eventRef.id)
                            .update({
                          'eventName': titleController.text,
                          'venue': venueController.text,
                          'type': selectedEvent,
                          'date': Timestamp.fromDate(eventDate!),
                          'startTime': Timestamp.fromDate(startDateTime),
                          'endTime': Timestamp.fromDate(endDateTime),
                          'parentFest': FirebaseFirestore.instance
                              .collection('fests')
                              .doc(docId),
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        showCustomSnackBar(
                            context, "Event Updated Successfully!");
                      }

                      Navigator.pop(context); // Close the dialog
                      _fetchText(); // Refresh UI
                    } catch (e) {
                      showCustomSnackBar(context,
                          "Error in Creating or Updating the event....");
                    }
                  }
                },
                child: add ? Text("Add") : Text("Update"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );
    },
  );
}

// Date Picker Function
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

// Time Picker Function
Widget _timePicker(BuildContext context, String label, TimeOfDay? time,
    Function(TimeOfDay) onTimePicked) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(time == null ? "$label: Not Set" : "$label: ${time.format(context)}",
          style: const TextStyle(fontSize: 16)),
      TextButton(
        child: const Text("Select"),
        onPressed: () async {
          TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            onTimePicked(picked);
          }
        },
      ),
    ],
  );
}

// Event Type Picker
Widget _eventPicker(
  BuildContext context,
  String label,
  String? selectedEvent,
  List<String> eventOptions,
  Function(String) onEventPicked,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          selectedEvent == null ? "$label: Not Set" : "$label: $selectedEvent",
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      TextButton(
        child: const Text("Choose"),
        onPressed: () async {
          String? picked = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text("Choose Event"),
                children: eventOptions.map((event) {
                  return SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, event);
                    },
                    child: Text(event),
                  );
                }).toList(),
              );
            },
          );

          if (picked != null) {
            onEventPicked(picked);
          }
        },
      ),
    ],
  );
}
