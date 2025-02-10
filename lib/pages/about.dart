import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:beyond_borders/main.dart';
import 'package:beyond_borders/pages/custom_drawer.dart';
import 'package:beyond_borders/pages/custom_appbar.dart';

class about extends StatelessWidget {
  const about({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: buildPadding(),
      ),
    );
  }

  Widget buildPadding() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Prevents unnecessary stretching
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/about_airplane.svg',
                height: 100, // Adjusted for better responsiveness
                width: 100,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'About Beyond Borders',
                  style: TextStyle(
                    fontFamily: "Batangas",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Beyond Borders is an innovative app designed to help you explore and experience the world in a unique way. '
                'We aim to break down the barriers of traditional travel apps by offering personalized recommendations, interactive maps, '
                'and user-generated content that allows you to discover new places beyond the usual tourist spots.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/about_feature.svg',
                height: 100,
                width: 100,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Our Features Include:',
                  style: TextStyle(
                    fontFamily: "Batangas",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '- Personalized Travel Recommendations\n'
                '- Interactive Maps\n'
                '- User-generated Content\n'
                '- Community Reviews and Ratings\n'
                '- Offline Mode for Easy Access',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/about_contact.svg',
                height: 100,
                width: 100,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Contact Us:',
                  style: TextStyle(
                    fontFamily: "Batangas",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'For any inquiries or feedback, reach us at:\n'
                'Email: support@beyondborders.com\n'
                'Phone: +123 456 7890',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '© 2025 Beyond Borders. All rights reserved.',
              style: TextStyle(
                fontFamily: "Batangas",
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
