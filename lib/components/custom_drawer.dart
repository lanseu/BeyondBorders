import 'package:beyond_borders/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:beyond_borders/pages/about.dart';
import 'package:beyond_borders/pages/destinations.dart';
import 'package:beyond_borders/authentication/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beyond_borders/pages/settings.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  String _fullName = 'Guest User';
  String _email = '';
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // User is logged in
        setState(() {
          _isLoggedIn = true;
          _email = currentUser.email ?? '';
        });

        // Get additional user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            _fullName = userData['fullName'] ?? 'User';
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DrwHeader(
                fullName: _fullName,
                email: _email,
                isLoggedIn: _isLoggedIn,
              ),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Expanded(child: DrwListView()),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context); // Close drawer first
                _isLoggedIn
                    ? _signOut(context)
                    : Navigator.push(context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/airplane_departure.svg',
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isLoggedIn ? "Logout" : "Login",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
            (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}

class DrwHeader extends StatelessWidget {
  final String fullName;
  final String email;
  final bool isLoggedIn;

  const DrwHeader({
    super.key,
    required this.fullName,
    required this.email,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xff95C7DF),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: isLoggedIn
                ? Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : "U",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xff95C7DF),
              ),
            )
                : const Icon(Icons.person, size: 50, color: Color(0xff95C7DF)),
          ),
          const SizedBox(height: 10),
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            isLoggedIn ? email : "Sign in to continue",
            style: const TextStyle(
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

  const HoverListTile({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

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
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xff95C7DF) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            SvgPicture.asset(widget.iconPath, height: 24, width: 24),
            const SizedBox(width: 15),
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
  const DrwListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        HoverListTile(
          title: "Home",
          iconPath: 'assets/icons/home_icon.svg',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Destination())),
        ),
        const SizedBox(height: 10),
        HoverListTile(
          title: "Profile",
          iconPath: 'assets/icons/registration_icon.svg',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Profile())),
        ),
        const SizedBox(height: 10),
        HoverListTile(
          title: "Settings",
          iconPath: 'assets/icons/destination_icon.svg',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const SettingsPage())),
        ),
        const SizedBox(height: 10),
        HoverListTile(
          title: "About",
          iconPath: 'assets/icons/about_icon.svg',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const about())),
        ),
        const SizedBox(height: 10),
        HoverListTile(
          title: "Community",
          iconPath: 'assets/icons/community.svg',
          onTap: () => Navigator.pushNamed(context, '/community'),
        ),
      ],
    );
  }
}