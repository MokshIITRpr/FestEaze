import 'package:flutter/material.dart';

class ImageBuilder extends StatefulWidget {
  const ImageBuilder({super.key});

  @override
  State<ImageBuilder> createState() => _ImageBuilderState();
}

class _ImageBuilderState extends State<ImageBuilder> {
  final PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    // List of image URLs
    final List<String> _images = [
      'assets/Indian_Institute_of_Technology_Ropar_logo.png',
      'assets/Indian_Institute_of_Technology_Ropar_logo.png',
      'assets/Indian_Institute_of_Technology_Ropar_logo.png',
      'assets/Indian_Institute_of_Technology_Ropar_logo.png'
    ];

    return Container(
      width: 120,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
            width: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(2, 2),
                  blurRadius: 12,
                  color: Color.fromRGBO(0, 0, 0, 0.16),
                )
              ],
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(_images[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
