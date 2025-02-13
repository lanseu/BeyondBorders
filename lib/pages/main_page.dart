import 'package:beyond_borders/main.dart';
import 'package:flutter/material.dart';
import 'package:beyond_borders/pages/main_page.dart';
import 'home.dart';

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
                  MaterialPageRoute(builder: (context) => HomePage()),
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
            bottom: 50,
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
                SizedBox(height: 20),

                // Get Started Button (only on last page)
                if (_currentPage == onboardingData.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Get Started", style: TextStyle(color: Colors.white, fontSize: 18)),
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

  const OnboardingPage({
    required this.image,
    required this.title,
    required this.highlight,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 300, fit: BoxFit.cover),
          SizedBox(height: 30),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: title + " ",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextSpan(
                  text: highlight,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
