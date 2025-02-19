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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Spacer(), // Adds space between the title and the button
            IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit,
                  color: Colors.deepPurpleAccent),
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
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }
}
