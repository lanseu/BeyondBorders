import 'package:beyond_borders/main.dart';
import 'package:flutter/material.dart';
import 'package:beyond_borders/authentication/main_page.dart';
import '../authentication/login.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Life is short and the world is",
      "highlight": "wide",
      "description": "At Beyond Borders, we bring you the best travel experiences worldwide.",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Discover new",
      "highlight": "adventures",
      "description": "Explore different destinations and cultures with our travel plans.",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Make every journey",
      "highlight": "memorable",
      "description": "Create lasting memories with friends and loved ones.",
    }
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return OnboardingPage(
                image: onboardingData[index]["image"]!,
                title: onboardingData[index]["title"]!,
                highlight: onboardingData[index]["highlight"]!,
                description: onboardingData[index]["description"]!,
                screenHeight: screenHeight,
                screenWidth: screenWidth,
              );
            },
          ),

          // Skip button
          Positioned(
            top: 40,
            right: 20,
            child: _currentPage != onboardingData.length - 1
                ? TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text(
                "Skip",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : SizedBox(),
          ),

          // Page indicator and Get Started button
          Positioned(
            bottom: screenHeight * 0.05,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page Indicator (Dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                        (index) => buildDot(index: index),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Get Started Button (only on last page)
                if (_currentPage == onboardingData.length - 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(screenWidth * 0.7, screenHeight * 0.07),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Get Started", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dots Indicator
  Widget buildDot({required int index}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 20 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Onboarding Page Widget
class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String highlight;
  final String description;
  final double screenHeight;
  final double screenWidth;

  const OnboardingPage({
    required this.image,
    required this.title,
    required this.highlight,
    required this.description,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: screenHeight * 0.5, fit: BoxFit.fill),
          SizedBox(height: screenHeight * 0.05),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: title + " ",
                  style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextSpan(
                  text: highlight,
                  style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
