import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:beyond_borders/pages/destinations.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right:16.0, bottom: 20),
        child: ListView(
          children: [
            // Lottie animation
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Lottie.asset(
                  "assets/animations/beyond_borders_main.json",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),

            // Welcome text
            Text(
              'Welcome to the Beyond Borders',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Name text field with Icon
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person), // Added Icon
              ),
            ),
            SizedBox(height: 16),

            // Email text field with Icon
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter your email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email), // Added Icon
              ),
            ),
            SizedBox(height: 16),

            // Password text field with Icon
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter your password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock), // Added Icon
              ),
            ),
            SizedBox(height: 32),

            // Onboard button with success dialog
            ElevatedButton(
              onPressed: () {
                _showSuccessDialog(context);
              },
              child: Text('On Board'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show Success Dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Prevents excessive height
            children: [
              // Lottie Animation
              SizedBox(
                height: 150, // Adjust as needed
                child: Lottie.asset(
                  "assets/animations/success.json",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16), // Space between animation & text
              Text(
                "Welcome to Beyond Borders",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Destination()),
                  );
                },
                child: Text(
                  "OK",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

