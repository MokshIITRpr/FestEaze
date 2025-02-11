import 'package:flutter/material.dart';

class Ar24 extends StatefulWidget {
  const Ar24({super.key});

  @override
  State<Ar24> createState() => _Ar24State();
}

class _Ar24State extends State<Ar24> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _imagePaths = [
    'assets/test_img1.jpg',
    'assets/test_img2.jpg',
    'assets/test_img3.jpeg',
    'assets/test_img4.jpeg',
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
        appBar: AppBar(
          title:
            Text('Aarohan 2024', style: TextStyle(fontWeight: FontWeight.bold)),
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
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "About",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Aarohan 2024 dfonskdlcnlskdnclksdnclknsdlkcnklsdncpsdcomsdmcsmdckscdmklsdmclkmdkcmlskdmclkmsckdmclskdmclkdmscoksdnfionsdoipismcpismcpimapij0isjfimiomj8jioifmjiodsjojdfsoj iofjgoijsfiogjiojsfiogjiofdjgo oifjgiojsiodfgjposjfgi iojgfiojsdfiogj oisdfjgiojfdiogjiofdjsogijiodfjgojdsfiojgio oifjgiosjfgiojiosdfjgiojsfog[josdjfguojsouj] pofvjpmvkmkv iosfiojdifsj kdfvlsdfijisfdjijfivjifvojojnfdvisdovifiosijvoisdjfvoijsiodfvjviuhuju oudfjgojsdfoigjgiojf ",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Tournaments & Leaderboard",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Sports such as Football, Basketball, Cricket,  fnvuidjsfojiopdsdjfvojioddfjviojdojpfguihivniudfhvuddvoidfoivjoijfoviodidjfvoidfoiviojdoifvoudfnovunuddfun oifjoijsdiofjiojfd ifjdvoijdfoijovijviojodifjviojoifjovosjovijodisfjviojdiofjvoijuhuhunvvuinsiviunfovisjfoivjoijfuhsoviosbfviosyfvboisiychsinuishf isdodfbvyidfdiuv iuhifniaavufduv ",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Pronite",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Pronite had _______ and the band _______ fnvuidjsfojiopdsdjfvojioddfjviojdojpfguihivniudfhvuddvoidfoivjoijfoviodidjfvoidfoiviojdoifvoudfnovunuddfun oifjoijsdiofjiojfd ifjdvoijdfoijovijviojodifjviojoifjovosjovijodisfjviojdiofjvoijuhuhunvvuinsiviunfovisjfoivjoijfuhsoviosbfviosyfvboisiychsinuishf isdodfbvyidfdiuv iuhifniaavufduv uiavuiohiufuhukaviuphfguphf uahfuphfuihuahuifvhd ahfipuhfcpuahjsddpuchjupjdafpuihvh piausdfhuipahdsuipvhapudshfipadfhguhpdfhgpuvhadpfiughp upfhvauiphfdpguhspfiuhpudfhgpuhapiufhgpuihdfpuihafuphvuphafviupahvpuihafpvuhadpfuvhpiaufhpuihvipuahpfdiuvhuphdfv ",
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