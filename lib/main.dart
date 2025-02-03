import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trial_project/pages/about.dart';
import 'package:trial_project/pages/destinations.dart';
import 'package:trial_project/pages/home.dart';
import 'package:trial_project/pages/main_page.dart';
import 'package:trial_project/pages/registration.dart';

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
        title: Text("Home Page",
        style: TextStyle(
          fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Home(),
      drawer: Drawer(
        child: ListView(
          children: [
            DrwHeader(),
            DrwListView(),
          ],
        ),
      ),
    );
  }
}

class DrwHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
          color: Colors.black
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage("assets/images/avatar.jpg"),
          ),
          SizedBox(height: 20),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class DrwListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text("Main Page"),
            leading: SvgPicture.asset('assets/icons/flying.svg',
              height: 24,
              width: 24,
            ),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => main_page())),
          ),
          ListTile(
            title: Text("Registration"),
            leading: SvgPicture.asset('assets/icons/museum.svg',
              height: 24,
              width: 24,
            ),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => registration())),
          ),
          ListTile(
            title: Text("About"),
            leading: SvgPicture.asset('assets/icons/hotel.svg',
              height: 24,
              width: 24,
            ),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => about())),
          ),
          ListTile(
            title: Text("Destinations"),
            leading: SvgPicture.asset('assets/icons/travelling.svg',
              height: 24,
              width: 24,
            ),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => Destination())),
          ),
        ],
      ),
    );
  }
}
