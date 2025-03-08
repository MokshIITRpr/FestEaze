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
        title: const Text('About Us',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 84, 91, 216),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Indian Institute of Technology Ropar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 84, 91, 216),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Indian Institute of Technology Ropar (IIT Ropar) is one of the premier institutions of higher education in India. Established in 2008 by the Government of India under the mentorship of IIT Delhi, IIT Ropar has rapidly gained recognition for its excellence in academics, research, and innovation. The institute is located in Rupnagar, Punjab, along the banks of the Sutlej River, providing a serene and conducive environment for learning and research.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Annual Festivals",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 84, 91, 216),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Zeitgeist",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              " is the annual cultural festival of IIT Ropar and one of the most anticipated college fests in North India. It features a mix of music, dance, drama, fashion, and literary events. The fest brings together students from different colleges and universities, providing a vibrant platform for artistic expression and entertainment.\n\n",
                        ),
                        TextSpan(
                          text: "Advitiya",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              " is IIT Ropar's annual technical festival, aimed at fostering innovation, creativity, and problem-solving skills. It serves as a platform for students to showcase their technical expertise through various competitions, workshops, and exhibitions.\n\n",
                        ),
                        TextSpan(
                          text: "Aarohan",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              " is the annual sports fest of IIT Ropar, bringing together athletes and sports enthusiasts from various colleges across the country. It serves as a platform to showcase sporting talent, teamwork, and competitive spirit in a variety of sports and fitness challenges. The fest promotes a culture of sportsmanship and healthy competition among students.",
                        ),
                      ],
                    ),
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
