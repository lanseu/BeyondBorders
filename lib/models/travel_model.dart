import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TravelCategory {
  String name;
  String iconPath;
  String duration;
  String distance;
  String destination;
  Color boxColor;
  bool viewIsSelected;

  TravelCategory({
    required this.name,
    required this.iconPath,
    required this.duration,
    required this.distance,
    required this.destination,
    required this.boxColor,
    this.viewIsSelected = true,
  });

  static List<TravelCategory> getTravelCategories() {
    List<TravelCategory> travelCategories = [];

    travelCategories.add(
      TravelCategory(
        name: "London Bridge",
        iconPath: "assets/icons/london_bridge.svg",
        duration: "1 day",
        distance: "10 km",
        destination: "London, United Kingdom",
        boxColor: const Color(0xFFC8E6C9),
      ),
    );
    travelCategories.add(
      TravelCategory(
        name: "Japanese Shrine",
        iconPath: "assets/icons/japan_shrine.svg",
        duration: "2 days",
        distance: "15 km",
        destination: "Kyoto, Japan",
        boxColor: const Color(0xFFFFF9C4),
      ),
    );
    travelCategories.add(
      TravelCategory(
        name: "Egypt Pyramid",
        iconPath: "assets/icons/pyramid.svg",
        duration: "3 days",
        distance: "25 km",
        destination: "Giza, Egypt",
        boxColor: const Color(0xFFFFCCBC),
      ),
    );
    travelCategories.add(
      TravelCategory(
        name: "Eiffel Tower - Paris",
        iconPath: "assets/icons/eiffel_tower.svg",
        duration: "1 day",
        distance: "5 km",
        destination: "Paris, France",
        boxColor: const Color(0xFFE1BEE7),
      ),
    );
    travelCategories.add(
      TravelCategory(
        name: "Statue of Liberty",
        iconPath: "assets/icons/statue_of_liberty.svg",
        duration: "1 day",
        distance: "8 km",
        destination: "New York, USA",
        boxColor: const Color(0xFFB3E5FC),
      ),
    );

    return travelCategories;
  }
}
