import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActivityModel {
  String name;
  String iconPath;
  Color boxColor;
  String description; // New field for activity description

  ActivityModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
    required this.description, // Added required parameter for description
  });

  static List<ActivityModel> getActivities() {
    List<ActivityModel> activities = [];

    activities.add(
      ActivityModel(
        name: "Diving",
        iconPath: "assets/icons/diving.svg",
        boxColor: const Color(0xFFB3E5FC), // Light blue
        description: "Explore the underwater world and enjoy marine life.",
      ),
    );
    activities.add(
      ActivityModel(
        name: "Museum",
        iconPath: "assets/icons/museum.svg",
        boxColor: const Color(0xFFD1C4E9), // Soft purple
        description: "Discover history, art, and culture through exhibits.",
      ),
    );
    activities.add(
      ActivityModel(
        name: "Hotel",
        iconPath: "assets/icons/hotel.svg",
        boxColor: const Color(0xFFFFE0B2), // Light orange
        description: "Relax and enjoy luxurious accommodations.",
      ),
    );
    activities.add(
      ActivityModel(
        name: "BBQ",
        iconPath: "assets/icons/bbq.svg",
        boxColor: const Color(0xFFFFCDD2), // Soft red
        description: "Savor delicious grilled dishes with family and friends.",
      ),
    );
    activities.add(
      ActivityModel(
        name: "Hot Air Balloon",
        iconPath: "assets/icons/hot_air_balloon.svg",
        boxColor: const Color(0xFFC5E1A5), // Light green
        description: "Enjoy breathtaking aerial views from a hot air balloon.",
      ),
    );
    activities.add(
      ActivityModel(
        name: "Flying",
        iconPath: "assets/icons/flying.svg",
        boxColor: const Color(0xFFFFF9C4), // Pale yellow
        description: "Experience the thrill of soaring through the skies.",
      ),
    );
    activities.add(
      ActivityModel(
        name: "Travelling",
        iconPath: "assets/icons/travelling.svg",
        boxColor: const Color(0xFFE1BEE7), // Soft pink
        description: "Explore new places and create unforgettable memories.",
      ),
    );
    activities.add(
      ActivityModel(
        name: "Photography",
        iconPath: "assets/icons/photog.svg",
        boxColor: const Color(0xFFCFD8DC), // Light gray-blue
        description: "Capture stunning moments and landscapes through the lens.",
      ),
    );

    return activities;
  }
}
