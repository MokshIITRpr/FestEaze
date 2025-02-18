import 'package:flutter/material.dart';

class Event {
  final String name;
  final String date;
  final List<Color> colors;
  final Widget navigateTo;

  Event({
    required this.name,
    required this.date,
    required this.colors,
    required this.navigateTo,
  });
}
