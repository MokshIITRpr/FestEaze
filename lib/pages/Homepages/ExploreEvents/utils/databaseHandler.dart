import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference> addFestWithEvents(
      Map<String, dynamic> csvData) async {
    try {
      // ✅ Step 1: Convert date fields safely
      DateTime startDate = _safeParseDate(csvData['startDate']);
      DateTime endDate = _safeParseDate(csvData['endDate']);

      // ✅ Step 2: Add fest to "fests" collection
      DocumentReference festRef = await _firestore.collection('fests').add({
        'title': csvData['eventName'],
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'about': csvData['about'],
        'pronite': [],
        'manager': [],
        'subEvents': [],
        'createdAt': Timestamp.now(),
      });

      print("✅ Fest added with ID: ${festRef.id}");

      List<DocumentReference> flagshipEventIds = [];
      List<DocumentReference> subEventIds = [];

      // ✅ Step 3: Function to add an event to "events" collection
      Future<DocumentReference> addEvent(Map<String, dynamic> eventData) async {
        if (eventData['eventName'] == null) {
          throw Exception("Event name is missing!");
        }

        DateTime? eventDate = eventData['eventDate'] != null
            ? _safeParseDate(eventData['eventDate'])
            : null;

        DocumentReference eventRef = await _firestore.collection('events').add({
          'eventName': eventData['eventName'],
          'date': eventDate != null ? Timestamp.fromDate(eventDate) : null,
          'startTime': eventData['eventStartTime'] != null
              ? Timestamp.fromDate(
                  _parseTime(eventDate, eventData['eventStartTime']))
              : null,
          'endTime': eventData['eventEndTime'] != null
              ? Timestamp.fromDate(
                  _parseTime(eventDate, eventData['eventEndTime']))
              : null,
          'venue': eventData['venue'] ?? "TBA",
          'description': eventData['description'] ?? "No description",
          'parentFest': festRef, // 🔥 Store as DocumentReference
          'createdAt': Timestamp.now(),
        });

        return eventRef; // ✅ Return only document ID
      }

      // ✅ Step 4: Add flagship events (Ensure it's not null)
      if (csvData['flagshipEvents'] != null) {
        for (var event in csvData['flagshipEvents']) {
          DocumentReference eventId = await addEvent(event);
          flagshipEventIds.add(eventId);
          print("✅ Flagship event added: $eventId");
        }
      }

      // ✅ Step 5: Add sub-events (Ensure it's not null)
      if (csvData['subEvents'] != null) {
        for (var event in csvData['subEvents']) {
          DocumentReference eventId = await addEvent(event);
          subEventIds.add(eventId);
          print("✅ Sub-event added: $eventId");
        }
      }

      // ✅ Step 6: Update the fest document with event references
      await festRef.update({
        'pronite': flagshipEventIds, // Store only Event IDs, not paths
        'subEvents': subEventIds,
      });

      print("✅ Fest updated with event references.");
      return festRef; // ✅ Return the fest reference
    } catch (e) {
      print("❌ Error adding fest and events: $e");
      throw Exception("Failed to add fest: $e");
    }
  }

  // ✅ Safe DateTime parsing function
  DateTime _safeParseDate(dynamic date) {
    if (date is DateTime) {
      return date;
    } else if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        print("⚠️ Invalid date format: $date");
      }
    }
    return DateTime.now(); // Fallback if date is invalid
  }

  // ✅ Fix: Helper function to parse time
  DateTime _parseTime(DateTime? eventDate, String? time) {
    if (eventDate == null || time == null)
      return DateTime.now(); // Handle null values

    try {
      List<String> timeParts = time.split(':');
      int hours = int.parse(timeParts[0]);
      int minutes = int.parse(timeParts[1]);

      return DateTime(
          eventDate.year, eventDate.month, eventDate.day, hours, minutes);
    } catch (e) {
      print("⚠️ Invalid time format: $time");
      return DateTime.now();
    }
  }
}
