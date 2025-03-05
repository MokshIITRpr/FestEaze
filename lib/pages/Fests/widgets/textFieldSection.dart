import 'package:flutter/material.dart';

class TextFieldSection extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onEdit;

  const TextFieldSection({
    super.key,
    required this.title,
    required this.controller,
    required this.isEditing,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Left-align the content
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start, // Left-align the title
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Change title text color to white
              ),
            ),
            Spacer(), // Adds space between the title and the button
            IconButton(
              icon: Icon(
                isEditing ? Icons.check : Icons.edit,
                color: Color(0xFF1DB954), // Spotify Green color for the icon
              ),
              onPressed: onEdit,
            ),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditing,
          maxLines: null,
          style: TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              // Default border
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              // Border when TextField is not focused
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              // Border when TextField is focused
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
