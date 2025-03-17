// In user_information.dart
class UserInformation {
  final String fullName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String location;

  // Static list to store all registered users
  static List<UserInformation> _allUsers = [
    // Start with some sample users
    // You can keep or remove these sample users
  ];

  UserInformation({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.location,
  });

  // Method to get all users
  static List<UserInformation> getAllUsers() {
    return _allUsers;
  }

  // Method to add a new user
  static void addUser(UserInformation user) {
    _allUsers.add(user);
  }
}