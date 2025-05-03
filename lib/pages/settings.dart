import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:beyond_borders/authentication/login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:beyond_borders/components/custom_appbar.dart';
import 'package:beyond_borders/components/custom_drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;
  final _authService = FirebaseAuth.instance;
  User? _currentUser;
  String _userId = '';

  // Location status
  bool _locationEnabled = false;

  // Notification settings
  bool _notifyLikes = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  Future<void> _loadUserData() async {
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      setState(() {
        _userId = _currentUser!.uid;
      });
    }
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check location permission status
      _checkLocationPermission();

      // Load notification settings
      setState(() {
        _notifyLikes = prefs.getBool('notify_likes') ?? true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading settings: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationEnabled = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    setState(() {
      _locationEnabled = (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse);
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save notification settings
      await prefs.setBool('notify_likes', _notifyLikes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        await Geolocator.openLocationSettings();
        return;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // User denied permissions forever, direct them to app settings
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permissions are permanently denied, please enable them in app settings'),
            action: SnackBarAction(
              label: 'SETTINGS',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }

      // Update status after request
      setState(() {
        _locationEnabled = (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting location permission: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .delete();

        // Delete user authentication account
        await _currentUser?.delete();

        // Sign out and navigate to login
        await _authService.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Login()),
              (route) => false,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Location Settings'),
                tiles: [
                  SettingsTile(
                    title: const Text('Location Access'),
                    description: Text(_locationEnabled
                        ? 'Location access is enabled'
                        : 'App needs location access to find nearby activities'),
                    leading: Icon(
                      _locationEnabled ? Icons.location_on : Icons.location_off,
                      color: _locationEnabled ? Colors.green : Colors.grey,
                    ),
                    onPressed: (context) {
                      _requestLocationPermission();
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Notifications'),
                tiles: [
                  SettingsTile.switchTile(
                    title: const Text('Likes on your posts'),
                    leading: const Icon(Icons.thumb_up),
                    initialValue: _notifyLikes,
                    onToggle: (value) {
                      setState(() {
                        _notifyLikes = value;
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Account'),
                tiles: [
                  SettingsTile(
                    title: const Text('Delete Account'),
                    description: const Text('Permanently delete your account and all data'),
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: (context) {
                      _deleteAccount();
                    },
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}