import 'package:flutter/material.dart';

class ImageSlider extends StatelessWidget {
  final PageController pageController;
  final List<String> imagePaths;

  const ImageSlider(
      {super.key, required this.pageController, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: imagePaths.length,
            onPageChanged: (index) {
              // handle page change if necessary
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    imagePaths[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
