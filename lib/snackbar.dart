import 'package:flutter/material.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  IconData? icon,
}) {
  // Use a color with an RGBO opacity value.
  final Color bgColor = backgroundColor ?? Color.fromRGBO(84, 91, 216, 0.85);

  final snackBar = SnackBar(
    content: Row(
      children: [
        if (icon != null)
          Icon(icon, color: Colors.white, size: 20),
        if (icon != null)
          const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: bgColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    duration: const Duration(seconds: 3),
    elevation: 6,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
