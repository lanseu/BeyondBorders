import 'package:flutter/material.dart';
import 'package:beyond_borders/pages/custom_drawer.dart';
import 'package:beyond_borders/pages/custom_appbar.dart';

class main_page extends StatelessWidget {
  const main_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      drawer: CustomDrawer(),
      body: buildPadding(),
    );
  }

  Padding buildPadding() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Welcome to the Main Page!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Text Field for Name
          const TextField(
            decoration: InputDecoration(
              labelText: 'Enter your name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 20),

          // Text Field for Email
          const TextField(
            decoration: InputDecoration(
              labelText: 'Enter your email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 20),

          // Text Field for Password
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Enter your password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 30),

          // Image Section
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/beyond_borders.png',  // Replace with your image asset path
                height: 200,  // Adjust the height
                width: 200,   // Adjust the width
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
