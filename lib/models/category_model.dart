import 'package:flutter/material.dart';

class CategoryModel {
  String name;
  String iconPath;
  Color boxColor;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
  });

  static List<CategoryModel> getCategories() {
    List<CategoryModel> categories = [];

    categories.add(
      CategoryModel(
        name: "Island",
        iconPath: "assets/icons/island.svg",
        boxColor: const Color(0xFFBFEFFF),
      ),
    );
    categories.add(
      CategoryModel(
        name: "Mountain",
        iconPath: "assets/icons/mountain.svg",
        boxColor: const Color(0xFFC8E6C9),
      ),
    );
    categories.add(
      CategoryModel(
        name: "Plane",
        iconPath: "assets/icons/plane.svg",
        boxColor: const Color(0xFFFFF9C4),
      ),
    );
    categories.add(
      CategoryModel(
        name: "Surf",
        iconPath: "assets/icons/surf.svg",
        boxColor: const Color(0xFFE1BEE7),
      ),
    );
    categories.add(
      CategoryModel(
        name: "Train",
        iconPath: "assets/icons/train.svg",
        boxColor: const Color(0xFFFFCCBC),
      ),
    );
    return categories;
  }
}
