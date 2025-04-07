import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:beyond_borders/pages/destinations.dart';
import 'package:beyond_borders/authentication/registration.dart';
import 'package:beyond_borders/authentication/custom_auth_appbar.dart';
import 'package:beyond_borders/services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  // Add this variable to track password visibility
  bool _obscurePassword = true;

  // Create instance of AuthService
  final AuthService _authService = AuthService();

  // Validation function
  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Function to handle form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Sign in with Firebase
        await _authService.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Show success dialog
        _showSuccessDialog(context);
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      // Wrap the body with a SafeArea for proper padding
      body: SafeArea(
        // Add SingleChildScrollView to handle overflow when keyboard appears
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie animation - add flexibility to resize
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Lottie.asset(
                        "assets/animations/beyond_borders_main.json",
                        height: MediaQuery.of(context).size.height * 0.2, // Responsive height
                        width: double.infinity,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),

                  // Welcome text
                  Text(
                    'Welcome to Beyond Borders',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),

                  // Email Text Field with validation
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Enter your email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) => _validateField(value, 'Email'),
                  ),
                  SizedBox(height: 16),

                  // Password Text Field with validation and toggle visibility
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword, // Use our toggle variable here
                    decoration: InputDecoration(
                      labelText: 'Enter your password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      // Add suffix icon button to toggle password visibility
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Change the icon based on the state
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          // Toggle password visibility state
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) => _validateField(value, 'Password'),
                  ),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _showForgotPasswordDialog(context);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Onboard button with validation
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Sign In'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Register now section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account yet? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Registration()),
                          );
                        },
                        child: Text(
                          "Register now",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Add extra padding at the bottom to ensure content is visible with keyboard
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0
                      ? 20
                      : 0),
                ],
              ),
            ),
          ),
        ),
      ),
      // Add resizeToAvoidBottomInset property to prevent bottom overflow
      resizeToAvoidBottomInset: true,
    );
  }

  // Show Success Dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Prevents excessive height
            children: [
              // Lottie Animation
              SizedBox(
                height: 150, // Adjust as needed
                child: Lottie.asset(
                  "assets/animations/success.json",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16), // Space between animation & text
              Text(
                "Welcome to Beyond Borders",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Destination()),
                  );
                },
                child: Text(
                  "OK",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show Forgot Password Dialog
  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    bool _obscureResetPassword = true; // For reset password visibility toggle if needed

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your email to receive a password reset link'),
              SizedBox(height: 16),
              TextFormField(
                controller: resetEmailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (resetEmailController.text.isNotEmpty) {
                  try {
                    await _authService.resetPassword(resetEmailController.text);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password reset email sent!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
  }
}