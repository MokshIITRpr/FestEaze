import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

class CsvImporter {
  static Future<Map<String, dynamic>?> importCsvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        print("⚠️ No file selected");
        return null;
      }

      String? filePath = result.files.single.path;
      String fileName = result.files.single.name; // Get the file name

      String contents;
      if (filePath != null) {
        // Read file from path (normal case)
        File file = File(filePath);
        contents = await file.readAsString();
      } else if (result.files.single.bytes != null) {
        // Read from memory (Scoped Storage / Android 10+)
        Uint8List fileBytes = result.files.single.bytes!;
        contents = String.fromCharCodes(fileBytes);
      } else {
        throw Exception("File reading failed: No path or bytes found");
      }

      print("📂 File selected: $fileName");
      print("📄 File contents:\n$contents");

      // Call CSV parsing function
      var csvData = CsvImporter.parseCsv(contents, fileName);
      print("✅ Parsed CSV Data: $csvData");
      print("📂 File imported successfully!");
      return csvData;
    } catch (e, stackTrace) {
      print("❌ Error while importing CSV: $e");
      print(stackTrace);
      return null;
    }
  }

  static Map<String, dynamic> parseCsv(String contents, String filePath) {
    List<List<dynamic>> csvTable =
        const CsvToListConverter().convert(contents, eol: '\n');

    print("Parsed CSV Table: $csvTable");

    // Extract fest details (First row)
    String festName = csvTable[1][0].toString();
    DateTime festStartDate = _parseDate(csvTable[1][1].toString());
    DateTime festEndDate = _parseDate(csvTable[1][2].toString());
    String aboutFest = csvTable[1][3].toString();

    // Extract flagship event count (Second row)
    int flagshipEventCount = int.tryParse(csvTable[2][0].toString()) ?? 0;

    List<Map<String, dynamic>> flagshipEvents = [];
    List<Map<String, dynamic>> subEvents = [];

    // Loop through the events and classify them
    for (int i = 3; i < csvTable.length; i++) {
      if (csvTable[i].isEmpty || csvTable[i][0] == null) continue;

      // Extract event details
      String eventName = csvTable[i][0].toString();
      String eventDate = csvTable[i][1].toString().isNotEmpty
          ? _formatDate(csvTable[i][1].toString())
          : "TBA";
      String eventStartTime = csvTable[i].length > 5
          ? _formatTime(csvTable[i][5].toString())
          : "TBA";
      String eventEndTime = csvTable[i].length > 6
          ? _formatTime(csvTable[i][6].toString())
          : "TBA";
      String venue = csvTable[i].length > 4 ? csvTable[i][4].toString() : "TBA";
      String description =
          csvTable[i].length > 3 ? csvTable[i][3].toString() : "No description";
      String type =
          csvTable[i].length > 7 ? csvTable[i][7].toString() : "No link";
      var event = {
        "eventName": eventName,
        "eventDate": eventDate,
        "eventStartTime": eventStartTime,
        "eventEndTime": eventEndTime,
        "venue": venue,
        "description": description,
        "type": type,
      };

      // Classify flagship and sub-events
      if (i - 3 < flagshipEventCount) {
        flagshipEvents.add(event);
      } else {
        subEvents.add(event);
      }
    }

    return {
      "eventName": festName,
      "startDate": festStartDate,
      "endDate": festEndDate,
      "about": aboutFest,
      "flagshipEvents": flagshipEvents,
      "subEvents": subEvents,
      "fileName": filePath.split('/').last,
    };
  }

  // Parse date safely
  static DateTime _parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      print("⚠️ Invalid date format: $dateString. Using default.");
      return DateTime(2030);
    }
  }

  // Ensure correct date format
  static String _formatDate(String dateString) {
    return dateString.isNotEmpty ? dateString : "TBA";
  }

  // Ensure correct time format
  static String _formatTime(String timeString) {
    if (timeString.isEmpty) return "TBA";

    try {
      List<String> parts = timeString.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
    } catch (e) {
      print("⚠️ Invalid time format: $timeString. Using default.");
      return "TBA";
    }
  }
}
