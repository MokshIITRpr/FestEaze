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
    'assets/iitropar11.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _autoSlideImages();
  }

  void _autoSlideImages() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _imagePaths.length;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 500),
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
          SizedBox(
            height: 200,
            child: PageView.builder(
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
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IIT Ropar Section
                  const Text(
                    'Indian Institute of Technology Ropar',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 84, 91, 216),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Indian Institute of Technology Ropar (IIT Ropar) is one of the premier institutions of higher education in India. Established in 2008 by the Government of India under the mentorship of IIT Delhi, IIT Ropar has rapidly gained recognition for its excellence in academics, research, and innovation. The institute is located in Rupnagar, Punjab, along the banks of the Sutlej River, providing a serene and conducive environment for learning and research.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Annual Festivals',
                    style: TextStyle(
                      fontSize: 20,
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
                          text: 'Zeitgeist',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' is the annual cultural festival of IIT Ropar and one of the most anticipated college fests in North India. It features a mix of music, dance, drama, fashion, and literary events. The fest brings together students from different colleges and universities, providing a vibrant platform for artistic expression and entertainment.\n\n',
                        ),
                        TextSpan(
                          text: 'Advitiya',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' is IIT Ropar\'s annual technical festival, aimed at fostering innovation, creativity, and problem-solving skills. It serves as a platform for students to showcase their technical expertise through various competitions, workshops, and exhibitions.\n\n',
                        ),
                        TextSpan(
                          text: 'Aarohan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' is the annual sports fest of IIT Ropar, bringing together athletes and sports enthusiasts from various colleges across the country. It serves as a platform to showcase sporting talent, teamwork, and competitive spirit in a variety of sports and fitness challenges. The fest promotes a culture of sportsmanship and healthy competition among students.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // FestEz Section
                  const Text(
                    'About FestEz',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 84, 91, 216),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to FestEz, your all-in-one platform for seamless event and fest management! Designed for colleges, universities, and event organizers, FestEz makes managing cultural, technical, and sports events effortless and organized — all from the convenience of your mobile device.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'What is FestEz?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 84, 91, 216),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'FestEz is a comprehensive event management app built specifically for college fests, cultural functions, technical symposiums, and sports tournaments. Whether you\'re participating, organizing, or just keeping up with the schedule, FestEz ensures everything you need is at your fingertips. The app beautifully integrates multiple event categories — from coding competitions to dance battles, basketball tournaments to music concerts — providing a unified platform where students and organizers can interact, register, and stay updated.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Why FestEz Helps',
                    style: TextStyle(
                      fontSize: 24,
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
                          text: '• For Students: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'No more scrambling for flyers or group-Chat updates. Discover, register, and get notified — all in one place.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '• For Organizers: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Simplify participant management, get real-time registration insights, and communicate instantly with attendees.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '• For Colleges: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Showcase your fest professionally, reduce paper waste, and ensure a well-coordinated, memorable experience for everyone.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Our Vision',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 84, 91, 216),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We believe in celebrating student creativity, talent, and teamwork. FestEz is dedicated to transforming campus events into an interactive, intuitive, and eco-friendly experience—bringing organizers and participants together through one powerful, easy-to-use app.',
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
