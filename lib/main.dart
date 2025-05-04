import 'package:beyond_borders/pages/community.dart';
import 'package:beyond_borders/pages/notifications.dart';
import 'package:flutter/material.dart';
import 'package:beyond_borders/components/custom_drawer.dart';
import 'package:beyond_borders/services/auth_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:beyond_borders/authentication/login.dart';
import 'package:beyond_borders/authentication/main_page.dart';
import 'package:beyond_borders/pages/destinations.dart';
import 'package:beyond_borders/pages/about.dart';
import 'package:beyond_borders/pages/profile.dart';
import 'package:beyond_borders/pages/settings.dart';
import 'package:beyond_borders/pages/wishlist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadingScreen(),
        '/login': (context) => Login(),
        '/onboarding': (context) => OnboardingScreen(),
        '/destinations': (context) => Destination(),
        '/about': (context) => about(),
        '/auth': (context) => AuthWrapper(),
        '/profile': (context) => Profile(),
        '/community': (context) => CommunityPage(),
        '/notifications': (context) => NotificationsPage(),
        'settings': (context) => SettingsPage(),
      },
      home: const HomeWithDrawer(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeWithDrawer()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/animations/loading.json", width: 200, height: 200, fit: BoxFit.contain),
            SizedBox(height: 20),
            Text("Loading...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class HomeWithDrawer extends StatefulWidget {
  const HomeWithDrawer({super.key});

  @override
  _HomeWithDrawerState createState() => _HomeWithDrawerState();
}

class _HomeWithDrawerState extends State<HomeWithDrawer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Destination(),
    WishlistPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
        ],
      ),
    );
  }
}
