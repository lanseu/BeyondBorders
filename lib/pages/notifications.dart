import 'package:flutter/material.dart';
import 'package:beyond_borders/components/custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late DatabaseReference _notificationsRef;
  late DatabaseReference _postsRef;

  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  // Theme colors to match community page
  final Color _primaryColor = const Color(0xFF1DA1F2); // Twitter blue
  final Color _lightGrayColor = const Color(0xFFE1E8ED);
  final Color _mediumGrayColor = const Color(0xFFAAB8C2);
  final Color _darkGrayColor = const Color(0xFF657786);
  final Color _textColor = const Color(0xFF14171A);

  @override
  void initState() {
    super.initState();
    _database.databaseURL =
    'https://beyond-borders-457415-default-rtdb.asia-southeast1.firebasedatabase.app/';
    _notificationsRef = _database.ref().child('notifications');
    _postsRef = _database.ref().child('posts');
    _fetchNotifications();
  }

  void _fetchNotifications() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Query notifications for the current user
    _notificationsRef
        .orderByChild('receiverId')
        .equalTo(currentUser.uid)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _notifications = [];
          Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
          if (values != null) {
            values.forEach((key, value) {
              _notifications.add(NotificationItem.fromRTDB(key, value));
            });
            _notifications.sort(
                    (a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _notifications = [];
          _isLoading = false;
        });
      }
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notifications: $error')),
      );
    });
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    try {
      await _notificationsRef.child(notification.id).update({
        'read': true,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update notification: $e')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      List<NotificationItem> unreadNotifications =
      _notifications.where((notification) => !notification.read).toList();

      for (var notification in unreadNotifications) {
        await _notificationsRef.child(notification.id).update({
          'read': true,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All notifications marked as read'),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark all as read: $e')),
      );
    }
  }

  Future<void> _deleteNotification(NotificationItem notification) async {
    try {
      await _notificationsRef.child(notification.id).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification removed'),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete notification: $e')),
      );
    }
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return 'Just now';

    DateTime notificationTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();
    Duration difference = now.difference(notificationTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(notificationTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Hero(
          tag: 'notification_icon',
          child: Material(
            color: Colors.transparent,
            child: Text(
              'Notifications',
              style: TextStyle(
                color: _textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        iconTheme: IconThemeData(color: _darkGrayColor),
        actions: [
          if (_notifications.any((notification) => !notification.read))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : _notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none,
                size: 64, color: _mediumGrayColor),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you get notifications, they\'ll appear here',
              style: TextStyle(
                color: _darkGrayColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : RefreshIndicator(
        color: _primaryColor,
        onRefresh: () async {
          setState(() {
            _isLoading = true;
          });
          _fetchNotifications();
        },
        child: ListView.separated(
          itemCount: _notifications.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          padding: const EdgeInsets.symmetric(vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            NotificationItem notification = _notifications[index];

            return Dismissible(
              key: Key(notification.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _deleteNotification(notification);
              },
              child: InkWell(
                onTap: () {
                  // Mark as read when tapped
                  if (!notification.read) {
                    _markAsRead(notification);
                  }

                  // Navigate to the post details if needed
                  // (This would be implemented in future updates)
                },
                child: Container(
                  color: notification.read ? Colors.white : Colors.blue.withOpacity(0.05),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: notification.senderProfileImage.isNotEmpty
                            ? NetworkImage(notification.senderProfileImage)
                            : null,
                        backgroundColor: _primaryColor,
                        child: notification.senderProfileImage.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // Notification content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with name and time
                            Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: 15, color: _textColor),
                                      children: [
                                        TextSpan(
                                          text: notification.senderName,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: ' ${notification.action}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTimestamp(notification.timestamp),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _darkGrayColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Post content preview
                            if (notification.contentPreview.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _lightGrayColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _lightGrayColor),
                                ),
                                child: Text(
                                  notification.contentPreview,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _darkGrayColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                            // Post image (if available)
                            if (notification.contentImageUrl != null &&
                                notification.contentImageUrl!.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _lightGrayColor),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: CachedNetworkImage(
                                    imageUrl: notification.contentImageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) => Container(
                                      color: _lightGrayColor.withOpacity(0.5),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: _lightGrayColor.withOpacity(0.5),
                                      child: Icon(Icons.image_not_supported, color: _darkGrayColor),
                                    ),
                                  ),
                                ),
                              ),

                            // Unread indicator
                            if (!notification.read)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NotificationItem {
  final String id;
  final String senderId;
  final String senderName;
  final String senderProfileImage;
  final String receiverId;
  final String type;
  final String action;
  final String contentId;
  final String contentPreview;
  final String? contentImageUrl;
  final int? timestamp;
  final bool read;

  NotificationItem({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderProfileImage,
    required this.receiverId,
    required this.type,
    required this.action,
    required this.contentId,
    required this.contentPreview,
    this.contentImageUrl,
    this.timestamp,
    required this.read,
  });

  factory NotificationItem.fromRTDB(String key, Map<dynamic, dynamic> data) {
    return NotificationItem(
      id: key,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'User',
      senderProfileImage: data['senderProfileImage'] ?? '',
      receiverId: data['receiverId'] ?? '',
      type: data['type'] ?? 'general',
      action: data['action'] ?? 'interacted with your post',
      contentId: data['contentId'] ?? '',
      contentPreview: data['contentPreview'] ?? '',
      contentImageUrl: data['contentImageUrl'],
      timestamp: data['timestamp'] as int?,
      read: data['read'] ?? false,
    );
  }
}