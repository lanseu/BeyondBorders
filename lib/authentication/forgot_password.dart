import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:beyond_borders/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _emailSent = false;
  String _debugMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _debugMessage = 'Checking email: $email';
    });

    try {
      // Log the email being checked
      debugPrint('Checking if email exists: $email');

      // Check if email exists first
      final emailExists = await _authService.checkEmailExists(email);

      debugPrint('Email exists check result: $emailExists');

      setState(() {
        _debugMessage = 'Email exists: $emailExists';
      });

      if (!emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No account found with this email address.'))
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Send the password reset email
      debugPrint('Sending password reset email to: $email');
      await _authService.sendPasswordResetEmail(email);
      debugPrint('Password reset email sent successfully');

      setState(() {
        _emailSent = true;
        _isLoading = false;
        _debugMessage = '';
      });
    } catch (e) {
      debugPrint('Error in password reset process: $e');

      setState(() {
        _isLoading = false;
        _debugMessage = 'Error: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _emailSent ? _buildEmailSentContent() : _buildResetForm(),
      ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!EmailValidator.validate(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendResetEmail,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Send Reset Link', style: TextStyle(fontSize: 16)),
          ),
          if (_debugMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                '(Debug) $_debugMessage',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.mark_email_read,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            'Password Reset Email Sent',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Back to Login', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}