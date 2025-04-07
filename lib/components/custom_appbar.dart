import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

AppBar buildAppBar(BuildContext context, {bool showBackButton = false}) {
  return AppBar(
    toolbarHeight: 75,
    backgroundColor: Color(0xFF15B0F8),
    elevation: 0,
    centerTitle: true,
    leading: showBackButton
        ? IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Handle back button press
              Navigator.of(context).pop();
            },
          )
        : Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
    title: SvgPicture.asset(
      'assets/icons/beyond_borders_header.svg',
      height: 175,
    ),
  );
}