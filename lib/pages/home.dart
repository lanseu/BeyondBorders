import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // To load SVGs for icons

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beyond Borders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add your search functionality here
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Banner or Welcome Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                "assets/images/beyond_borders.png",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Welcome Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome to Beyond Borders',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore new destinations, discover hidden gems, and experience the world like never before.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),

          // Destinations List Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Popular Destinations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          _buildDestinationItem(context, 'Paris', 'assets/icons/paris.svg'),
          _buildDestinationItem(context, 'Tokyo', 'assets/icons/tokyo.svg'),
          _buildDestinationItem(context, 'New York', 'assets/icons/new_york.svg'),

          // Action Buttons Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(context, 'Explore', Icons.explore),
                _buildActionButton(context, 'Wishlist', Icons.favorite),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // A helper method to build destination items with icons
  Widget _buildDestinationItem(BuildContext context, String destination, String iconPath) {
    return ListTile(
      leading: SvgPicture.asset(
        iconPath,  // Use the correct path to your SVG icon
        height: 40,
        width: 40,
      ),
      title: Text(destination),
      subtitle: const Text('Discover amazing places and experiences'),
      onTap: () {
        // You can navigate to a detail page for each destination
        print('Tapped on $destination');
      },
    );
  }

  // A helper method to build action buttons
  Widget _buildActionButton(BuildContext context, String title, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        // Define actions for the buttons
        print('$title button pressed');
      },
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
