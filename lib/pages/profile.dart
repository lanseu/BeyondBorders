import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:beyond_borders/authentication/login.dart';
import 'package:beyond_borders/components/custom_drawer.dart';
import 'package:beyond_borders/models/user_information.dart';
import 'package:beyond_borders/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beyond_borders/components/custom_appbar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isEditing = false;
  bool _isLoading = true;
  bool _showPassword = false;
  bool _obscurePassword = true;
  String? _userId;
  User? _currentUser;

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
      _currentUser = FirebaseAuth.instance.currentUser;
      _userId = _currentUser?.uid;

      if (_userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            _fullNameController.text = userData['fullName'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
            _dobController.text = userData['dateOfBirth'] ?? '';
            _locationController.text = userData['location'] ?? '';
            _emailController.text = _currentUser?.email ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter full name';
    } else if (value.length > 100) {
      return 'Name cannot exceed 100 characters';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter location';
    } else if (value.length > 50) {
      return 'Location cannot exceed 50 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    } else if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'Phone number must be 11 digits';
    }
    return null;
  }

  String? _validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter date of birth';
    }

    try {
      final dateOfBirth = DateTime.parse(value);
      final today = DateTime.now();
      final age = today.year - dateOfBirth.year -
          (today.month < dateOfBirth.month ||
              (today.month == dateOfBirth.month && today.day < dateOfBirth.day) ? 1 : 0);

      if (age < 7) {
        return 'You must be at least 7 years old';
      }
    } catch (e) {
      return 'Invalid date format';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (!_showPassword) return null;
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dobController.text.isNotEmpty
          ? DateTime.parse(_dobController.text)
          : DateTime.now().subtract(const Duration(days: 365 * 7)), // Default to 7 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Update user data in Firestore
        final userData = {
          'fullName': _fullNameController.text,
          'phone': _phoneController.text,
          'dateOfBirth': _dobController.text,
          'location': _locationController.text,
          'updatedAt': DateTime.now(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .update(userData);

        // Update email if it has changed
        if (_currentUser != null && _currentUser!.email != _emailController.text) {
          await _currentUser!.updateEmail(_emailController.text);
        }

        // Update password if provided
        if (_showPassword && _passwordController.text.isNotEmpty) {
          await _currentUser!.updatePassword(_passwordController.text);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        setState(() {
          _isEditing = false;
          _showPassword = false;
          _passwordController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
            (route) => false,
      );
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
      drawer: const CustomDrawer(),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Profile',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    _isEditing
                        ? Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          label: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              _showPassword = false;
                              _loadUserData();
                            });
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.save, color: Colors.blue),
                          label: const Text('Save', style: TextStyle(color: Colors.blue)),
                          onPressed: _updateProfile,
                        ),
                      ],
                    )
                        : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Manage your personal information and account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 25),
                // Profile picture section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          _fullNameController.text.isNotEmpty
                              ? _fullNameController.text[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Profile picture upload coming soon')),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Information fields
                TextFormField(
                  controller: _fullNameController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Full Name',
                    labelStyle: TextStyle(
                      color: _isEditing ? Colors.grey : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                    errorStyle: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Email Address',
                    labelStyle: TextStyle(
                      color: _isEditing ? Colors.grey : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorStyle: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold),
                  ),
                  validator: (value) => _validateField(value, 'email'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Phone',
                    labelStyle: TextStyle(
                      color: _isEditing ? Colors.grey : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.phone_outlined),
                    errorStyle: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold),
                  ),
                  validator: _validatePhone,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dobController,
                  enabled: _isEditing,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(
                      color: _isEditing ? Colors.grey : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    errorStyle: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold),
                    helperText: 'You must be at least 7 years old',
                    helperStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  validator: _validateDateOfBirth,
                  onTap: _isEditing ? () => _selectDate(context) : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _locationController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Location',
                      labelStyle: TextStyle(
                        color: _isEditing ? Colors.grey : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      errorStyle: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold)),
                  validator: _validateLocation,
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _showPassword,
                        activeColor: Colors.blue,
                        onChanged: (bool? value) {
                          setState(() {
                            _showPassword = value ?? false;
                          });
                        },
                      ),
                      const Text('Change password',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  if (_showPassword) ...[
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'New Password',
                        labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        errorStyle: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      validator: _validatePassword,
                    ),
                  ],
                ],
                const SizedBox(height: 30),
                if (!_isEditing)
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 60),
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Edit Profile'),
                        ),
                        const SizedBox(height: 15),
                        TextButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.grey),
                          label: const Text('Sign Out',
                              style: TextStyle(color: Colors.grey)),
                          onPressed: _signOut,
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.red),
                          label: const Text('Delete Account',
                              style: TextStyle(color: Colors.red)),
                          onPressed: _deleteAccount,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}