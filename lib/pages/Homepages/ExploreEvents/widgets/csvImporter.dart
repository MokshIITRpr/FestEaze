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

      return csvData;
    } catch (e, stackTrace) {
      print("❌ Error while importing CSV: $e");
      print(stackTrace);
      return null;
    }
  }

  static Map<String, dynamic> parseCsv(String contents, String fileName) {
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(contents);

    if (csvTable.length > 1) {
      return {
        "eventName": csvTable[1][0].toString(),
        "startDate": _parseDate(csvTable[1][1].toString()),
        "endDate": _parseDate(csvTable[1][2].toString()),
        "fileName": fileName,
      };
    }

    throw Exception("Invalid CSV Format");
  }

  static DateTime _parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      throw Exception("Invalid date format in CSV: $dateString");
    }
  }
}
