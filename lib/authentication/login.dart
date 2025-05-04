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

  // Error message strings
  String? _emailError;
  String? _passwordError;

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
    // Reset error messages first
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

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
        // Handle different error types and set appropriate error messages
        String errorMessage = e.toString();

        // Clean up the error message by removing "Exception:" prefix
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceAll('Exception:', '').trim();
        }

        if (errorMessage.contains('email')) {
          setState(() {
            _emailError = errorMessage;
          });
        } else if (errorMessage.contains('password')) {
          setState(() {
            _passwordError = errorMessage;
          });
        } else {
          // For general errors, show both
          setState(() {
            _emailError = errorMessage;
          });
        }
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/reset-password',
                        arguments: {'actionCode': 'test-code'},
                      );
                    },
                    child: Text('Test Reset Password'),
                  ),
                  // Email Text Field with validation
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Enter your email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                          // Add red border if there's an error
                          enabledBorder: _emailError != null
                              ? OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          )
                              : null,
                          focusedBorder: _emailError != null
                              ? OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          )
                              : null,
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // Remove the default error text (we'll show it separately below)
                          errorStyle: TextStyle(height: 0, fontSize: 0),
                        ),
                        validator: (value) => _validateField(value, 'Email'),
                      ),
                      // Show error message if exists
                      if (_emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                          child: Text(
                            _emailError!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Password Text Field with validation and toggle visibility
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword, // Use our toggle variable here
                        decoration: InputDecoration(
                          labelText: 'Enter your password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          // Add red border if there's an error
                          enabledBorder: _passwordError != null
                              ? OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          )
                              : null,
                          focusedBorder: _passwordError != null
                              ? OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          )
                              : null,
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // Remove the default error text (we'll show it separately below)
                          errorStyle: TextStyle(height: 0, fontSize: 0),
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
                      // Show error message if exists
                      if (_passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                          child: Text(
                            _passwordError!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
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

  // Show Forgot Password Dialog with error handling
  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    String? resetEmailError;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Reset Password'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Enter your email to receive a password reset link'),
                    SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: resetEmailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                            errorStyle: TextStyle(height: 0, fontSize: 0),
                            // Add red border if there's an error
                            enabledBorder: resetEmailError != null
                                ? OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            )
                                : null,
                            focusedBorder: resetEmailError != null
                                ? OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            )
                                : null,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        if (resetEmailError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                            child: Text(
                              resetEmailError!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                      ],
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
                      if (resetEmailController.text.isEmpty) {
                        setState(() {
                          resetEmailError = 'Email is required';
                        });
                        return;
                      }

                      try {
                        await _authService.resetPassword(resetEmailController.text);
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Password reset email sent!')),
                        );
                      } catch (e) {
                        String errorMessage = e.toString();

                        // Clean up the error message by removing "Exception:" prefix
                        if (errorMessage.contains('Exception:')) {
                          errorMessage = errorMessage.replaceAll('Exception:', '').trim();
                        }

                        setState(() {
                          resetEmailError = errorMessage;
                        });
                      }
                    },
                    child: Text('Send Reset Link'),
                  ),
                ],
              );
            }
        );
      },
    );
  }
}