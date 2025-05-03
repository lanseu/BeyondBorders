import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DatabaseReference _notificationsRef;
  late DatabaseReference _postsRef;

  NotificationService() {
    _database.databaseURL =
    'https://beyond-borders-457415-default-rtdb.asia-southeast1.firebasedatabase.app/';
    _notificationsRef = _database.ref().child('notifications');
    _postsRef = _database.ref().child('posts');
  }

  Future<void> createLikeNotification({
    required String postId,
    required String postOwnerId,
    required String postText,
    String? postImageUrl,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Don't create notification if user likes their own post
      if (currentUser.uid == postOwnerId) return;

      // Get sender data
      DocumentSnapshot senderSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      String senderName = 'User';
      String senderProfileImage = '';

      if (senderSnapshot.exists && senderSnapshot.data() != null) {
        Map<String, dynamic>? userData =
        senderSnapshot.data() as Map<String, dynamic>?;
        if (userData != null) {
          senderName = userData['fullName'] ?? 'User';
          senderProfileImage = userData['profileImage'] ?? '';
        }
      }

      // Create notification data
      Map<String, dynamic> notificationData = {
        'senderId': currentUser.uid,
        'senderName': senderName,
        'senderProfileImage': senderProfileImage,
        'receiverId': postOwnerId,
        'type': 'like',
        'action': 'liked your post',
        'contentId': postId,
        'contentPreview': postText.isNotEmpty ? postText : 'Image post',
        'contentImageUrl': postImageUrl,
        'timestamp': ServerValue.timestamp,
        'read': false,
      };

      // Save notification to database
      await _notificationsRef.push().set(notificationData);
    } catch (e) {
      print('Error creating like notification: $e');
    }
  }

  Future<int> getNewNotificationsCount() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return 0;

    try {
      // Query for unread notifications
      DatabaseEvent event = (await _notificationsRef
          .orderByChild('receiverId')
          .equalTo(currentUser.uid)
          .get()) as DatabaseEvent;

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
        int unreadCount = 0;

        if (values != null) {
          values.forEach((key, value) {
            if (value['read'] == false) {
              unreadCount++;
            }
          });
        }

        return unreadCount;
      }

      return 0;
    } catch (e) {
      print('Error getting new notifications count: $e');
      return 0;
    }
  }
}