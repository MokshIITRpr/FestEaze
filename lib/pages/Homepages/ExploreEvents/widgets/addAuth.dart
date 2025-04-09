import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fest_app/snackbar.dart';

void showAuthDialog(BuildContext context, String eventName) {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();
  String? errorMessage;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text("Add Fest Manager"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Email Id",
                  border: OutlineInputBorder(),
                ),
              ),
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
              child: const Text("Add"),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    QuerySnapshot querySnapshot = await _firestore
                        .collection('fests')
                        .where('title', isEqualTo: eventName)
                        .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      DocumentReference eventDoc =
                          querySnapshot.docs.first.reference;

                      await eventDoc.update({
                        'manager': FieldValue.arrayUnion([nameController.text])
                      });
                      // TODO : add checks for username matching in database and add user id here
                      print("Manager added successfully to the event!");
                    } else {
                      print("No event found with the name: $eventName");
                    }

                    Navigator.of(context).pop(); // Close dialog
                    // Use custom snackbar for success message.
                    showCustomSnackBar(
                      context,
                      '${nameController.text} updated as manager for ${eventName}',
                      backgroundColor: Colors.green,
                      icon: Icons.check_circle,
                    );
                  } catch (e) {
                    print("Error adding manager: $e");
                    // Use custom snackbar for error message.
                    showCustomSnackBar(
                      context,
                      'Error adding manager: ${e}',
                      backgroundColor: Colors.red,
                      icon: Icons.error,
                    );
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
