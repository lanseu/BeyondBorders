import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beyond_borders/authentication/login.dart';
import 'package:beyond_borders/pages/destinations.dart';
import 'package:beyond_borders/services/auth_service.dart';

import '../main.dart';

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // If we have a user, send them to the main app
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user != null) {
            return HomeWithDrawer();
          }
          // Otherwise, show login
          return Login();
        }

        // Show loading screen while checking auth state
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}