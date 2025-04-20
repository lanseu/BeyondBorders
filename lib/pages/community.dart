import 'dart:io';
import 'package:beyond_borders/authentication/custom_auth_appbar.dart';
import 'package:beyond_borders/components/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  late DatabaseReference _postsRef;

  List<Post> _posts = [];
  bool _isLoading = true;
  bool _isPostingLoading = false;

  // Controllers for creating post form
  final TextEditingController _postTextController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _imageFile;
  String _currentLocation = '';

  @override
  void initState() {
    super.initState();
    _database.databaseURL =
        'https://beyond-borders-f087e-default-rtdb.asia-southeast1.firebasedatabase.app/';
    _postsRef = _database.ref().child('posts');
    _fetchPosts();
  }

  void _fetchPosts() {
    _postsRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _posts = [];
          Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
          if (values != null) {
            values.forEach((key, value) {
              _posts.add(Post.fromRTDB(key, value));
            });
            _posts
                .sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _posts = [];
          _isLoading = false;
        });
      }
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _locationController.text = "Fetching location...";
      });

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String locality = place.locality ?? '';
        String adminArea = place.administrativeArea ?? '';
        _currentLocation =
            locality.isNotEmpty ? "$locality, $adminArea" : adminArea;

        setState(() {
          _locationController.text = _currentLocation;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
      setState(() {
        _locationController.text = "";
      });
    }
  }

  Future<void> _createPost() async {
    if (_postTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some text to your post')),
      );
      return;
    }

    setState(() {
      _isPostingLoading = true;
    });

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      DataSnapshot userSnapshot =
          await _database.ref().child('users').child(currentUser.uid).get();

      String username = 'User';
      String userProfileImage = '';

      if (userSnapshot.exists) {
        Map<dynamic, dynamic>? userData = userSnapshot.value as Map?;
        username = userData?['username'] ?? 'User';
        userProfileImage = userData?['profileImage'] ?? '';
      }

      String? imageUrl;

      if (_imageFile != null) {
        try {
          String fileName =
              'posts/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference storageRef = _storage.ref().child(fileName);

          await storageRef.putFile(_imageFile!);
          imageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          // Continue without image if upload fails
        }
      }

      Map<String, dynamic> postData = {
        'userId': currentUser.uid,
        'username': username,
        'userProfileImage': userProfileImage,
        'text': _postTextController.text.trim(),
        'location': _locationController.text.trim(),
        'imageUrl': imageUrl,
        'likes': 0,
        'likedBy': {},
        'timestamp': ServerValue.timestamp,
      };

      DatabaseReference newPostRef = _postsRef.push();
      await newPostRef.set(postData);

      setState(() {
        _postTextController.clear();
        _locationController.clear();
        _imageFile = null;
        _isPostingLoading = false;
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    } catch (e) {
      setState(() {
        _isPostingLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    }
  }

  Future<void> _toggleLike(Post post) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      DatabaseReference likedByRef =
          _postsRef.child(post.id).child('likedBy').child(currentUser.uid);

      DatabaseReference likesRef = _postsRef.child(post.id).child('likes');

      DataSnapshot likeSnapshot = await likedByRef.get();

      if (likeSnapshot.exists) {
        await likedByRef.remove();
        await likesRef.set(ServerValue.increment(-1));
      } else {
        await likedByRef.set(true);
        await likesRef.set(ServerValue.increment(1));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like: $e')),
      );
    }
  }

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Post',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _postTextController,
                  decoration: const InputDecoration(
                    hintText: 'What is up traveler?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: 'Where you at?',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _getCurrentLocation,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _imageFile != null
                          ? Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _imageFile!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _imageFile = null;
                                    });
                                  },
                                ),
                              ],
                            )
                          : OutlinedButton.icon(
                              icon: const Icon(Icons.image),
                              label: const Text('Add Image'),
                              onPressed: _pickImage,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPostingLoading ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isPostingLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Post'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(child: Text('No posts yet. Be the first to share!'))
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    _fetchPosts();
                  },
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      Post post = _posts[index];
                      bool userLiked = _auth.currentUser != null &&
                          post.likedBy.contains(_auth.currentUser!.uid);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    post.userProfileImage.isNotEmpty
                                        ? NetworkImage(post.userProfileImage)
                                        : null,
                                child: post.userProfileImage.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                post.username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: post.location.isNotEmpty
                                  ? Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14),
                                        const SizedBox(width: 4),
                                        Text(post.location),
                                      ],
                                    )
                                  : null,
                              trailing: Text(
                                _formatTimestamp(post.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            if (post.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(post.text),
                              ),
                            if (post.imageUrl != null &&
                                post.imageUrl!.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: post.imageUrl!,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Center(
                                  child: Icon(Icons.error),
                                ),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      userLiked
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_outlined,
                                      color: userLiked ? Colors.blue : null,
                                    ),
                                    onPressed: () => _toggleLike(post),
                                  ),
                                  Text('${post.likes}'),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.comment_outlined),
                                    onPressed: () {
                                      // Comment functionality could be added here
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share_outlined),
                                    onPressed: () {
                                      // Share functionality could be added here
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostSheet,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return 'Just now';

    DateTime postTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();
    Duration difference = now.difference(postTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(postTime);
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
}

// Modified Post model for Realtime Database
class Post {
  final String id;
  final String userId;
  final String username;
  final String userProfileImage;
  final String text;
  final String location;
  final String? imageUrl;
  final int likes;
  final List<String> likedBy;
  final int? timestamp;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfileImage,
    required this.text,
    required this.location,
    this.imageUrl,
    required this.likes,
    required this.likedBy,
    this.timestamp,
  });

  // Factory constructor for Realtime Database
  factory Post.fromRTDB(String key, Map<dynamic, dynamic> data) {
    // Handle likedBy which is a Map in RTDB
    List<String> likedByList = [];
    if (data['likedBy'] != null) {
      (data['likedBy'] as Map).forEach((key, value) {
        if (value == true) {
          likedByList.add(key.toString());
        }
      });
    }

    return Post(
      id: key,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'User',
      userProfileImage: data['userProfileImage'] ?? '',
      text: data['text'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      likes: data['likes'] ?? 0,
      likedBy: likedByList,
      timestamp: data['timestamp'] as int?,
    );
  }
}
