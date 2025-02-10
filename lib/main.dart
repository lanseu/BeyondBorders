import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:beyond_borders/pages/about.dart';
import 'package:beyond_borders/pages/destinations.dart';
import 'package:beyond_borders/pages/home.dart';
import 'package:beyond_borders/pages/main_page.dart';
import 'package:beyond_borders/pages/registration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: HomeWithDrawer(),
    );
  }
}

class HomeWithDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home Page",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Home(),
      drawer: CustomDrawer(), // Use CustomDrawer directly
    );
  }
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75, // Ensure correct width
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              DrwHeader(),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 10), // Add some space after header
          Expanded(child: DrwListView()), // Make ListView scrollable
          Divider(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListTile(
              leading: SvgPicture.asset(
                'assets/icons/plane.svg',
                height: 24,
                width: 24,
                color: Colors.red,
              ),
              title: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class DrwHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures full width
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff95C7DF),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center the content
        children: [
          SizedBox(height: 30),
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage("assets/images/avatar.jpg"),
          ),
          SizedBox(height: 10),
          Text(
            'Guest User',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "Sign in to continue",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class HoverListTile extends StatefulWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  HoverListTile({required this.title, required this.iconPath, required this.onTap});

  @override
  _HoverListTileState createState() => _HoverListTileState();
}

class _HoverListTileState extends State<HoverListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (hovering) {
        setState(() {
          _isHovered = hovering;
        });
      },
      child: Container(
        color: _isHovered ? const Color(0xff95C7DF) : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            SvgPicture.asset(widget.iconPath, height: 24, width: 24),
            SizedBox(width: 12),
            Text(
              widget.title,
              style: TextStyle(
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrwListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        HoverListTile(
          title: "Home",
          iconPath: 'assets/icons/flying.svg',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => main_page())),
        ),
        SizedBox(height: 10),
        HoverListTile(
          title: "Registration",
          iconPath: 'assets/icons/museum.svg',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => registration())),
        ),
        SizedBox(height: 10),
        HoverListTile(
          title: "Destinations",
          iconPath: 'assets/icons/travelling.svg',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Destination())),
        ),
        SizedBox(height: 10),
        HoverListTile(
          title: "About",
          iconPath: 'assets/icons/hotel.svg',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => about())),
        ),
      ],
    );
  }
}
