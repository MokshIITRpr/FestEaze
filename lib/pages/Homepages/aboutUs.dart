import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _imagePaths = [
    'assets/iitrpr.jpeg',
    'assets/zeitgeist.jpeg',
    'assets/advitiya.jpeg',
    'assets/aarohan.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _autoSlideImages();
  }

  void _autoSlideImages() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _imagePaths.length;
          _pageController.animateToPage(
            _currentIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
        _autoSlideImages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('About Us', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Image slider with auto-play
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _imagePaths.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          _imagePaths[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // About IIT Ropar & Annual Festivals
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Indian Institute of Technology Ropar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "IIT Ropar is one of the premier institutes of technology in India. Established in 2008, it is known for its cutting-edge research, world-class faculty, and vibrant student community. The institute offers a range of undergraduate, postgraduate, and doctoral programs across multiple disciplines.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Annual Festivals",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "IIT Ropar hosts several exciting events throughout the year. Some of the major festivals include:\n\n"
                    "🎵 **Zeitgeist** - The annual cultural fest, featuring music, dance, drama, and fun competitions.\n\n"
                    "🔬 **Advitiya** - The technical fest, bringing together students from across the country for coding, robotics, and innovative challenges.\n\n"
                    "🏆 **Sports Events** - Various intercollegiate and intramural sports events fostering teamwork and competition.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
