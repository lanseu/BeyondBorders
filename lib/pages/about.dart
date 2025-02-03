import 'package:flutter/material.dart';

class about extends StatelessWidget {
  const about({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Beyond Borders'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Beyond Borders',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Beyond Borders is an innovative app designed to help you explore and experience the world in a unique way. '
                  'We aim to break down the barriers of traditional travel apps by offering personalized recommendations, interactive maps, '
                  'and user-generated content that allows you to discover new places beyond the usual tourist spots.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Our Features Include:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
            const Text(
              'Contact Us:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'For any inquiries or feedback, reach us at:\n'
                  'Email: support@beyondborders.com\n'
                  'Phone: +123 456 7890',
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: Text(
                '© 2025 Beyond Borders. All rights reserved.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
