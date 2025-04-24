import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fest_app/snackbar.dart';

void showAuthDialog(BuildContext context, String docId, String position) {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();
  String? errorMessage;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: position == 'manager'
              ? const Text("Add Event Manager / Volunteer")
              : const Text("Add Volunteer"),
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
            if (position == "manager")
              ElevatedButton(
                child: const Text("Add Manager"),
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    try {
                      DocumentSnapshot docSnapshot = await _firestore
                          .collection('events')
                          .doc(docId) // Fetch directly using docId
                          .get();

                      if (docSnapshot.exists) {
                        DocumentReference eventDoc = docSnapshot.reference;

                        await eventDoc.update({
                          'manager':
                              FieldValue.arrayUnion([nameController.text])
                        });
                        print("Manager added successfully to the event!");

                        Navigator.of(context).pop(); // Close dialog
                        showCustomSnackBar(
                          context,
                          '${nameController.text} updated as manager',
                          backgroundColor: Colors.green,
                          icon: Icons.check_circle,
                        );
                      } else {
                        print("No event found with the docId : $docId");
                      }
                    } catch (e) {
                      print("Error adding manager: $e");
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
            ElevatedButton(
              child: const Text("Add Volunteer"),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    DocumentSnapshot docSnapshot = await _firestore
                        .collection('events')
                        .doc(docId) // Fetch directly using docId
                        .get();

                    if (docSnapshot.exists) {
                      DocumentReference eventDoc = docSnapshot.reference;

                      await eventDoc.update({
                        'volunteers':
                            FieldValue.arrayUnion([nameController.text])
                      });
                      print("Volunteer added successfully to the event!");

                      Navigator.of(context).pop(); // Close dialog
                      showCustomSnackBar(
                        context,
                        '${nameController.text} updated as volunteer',
                        backgroundColor: Colors.green,
                        icon: Icons.check_circle,
                      );
                    } else {
                      print("No event found with the docId : $docId");
                    }
                  } catch (e) {
                    print("Error adding manager: $e");
                    showCustomSnackBar(
                      context,
                      'Error adding volunteer: ${e}',
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
