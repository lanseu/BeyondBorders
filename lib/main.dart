import 'package:flutter/material.dart';
import 'package:beyond_borders/components/custom_drawer.dart';
import 'package:beyond_borders/services/auth_wrapper.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:beyond_borders/authentication/login.dart';
import 'package:beyond_borders/authentication/main_page.dart';
import 'package:beyond_borders/pages/destinations.dart';
import 'package:beyond_borders/pages/about.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      },
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
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
                "assets/animations/loading.json",
                width: 200, height: 200,
                fit: BoxFit.contain
            ),
            SizedBox(height: 20),
            Text(
              "Loading...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Home Page with Drawer
class HomeWithDrawer extends StatelessWidget {
  const HomeWithDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingScreen(),
      drawer: CustomDrawer(),
    );
  }
}