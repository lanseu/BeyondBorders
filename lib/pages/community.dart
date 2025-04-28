import 'dart:io';
import 'package:beyond_borders/authentication/custom_auth_appbar.dart';
import 'package:beyond_borders/components/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

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
  late DatabaseReference _usersRef;

  List<Post> _posts = [];
  bool _isLoading = true;
  bool _isPostingLoading = false;
  double _uploadProgress = 0.0;
  String _currentUserFullName = '';
  String _currentUserProfileImage = '';

  // Controllers for creating post form
  final TextEditingController _postTextController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _imageFile;
  String _currentLocation = '';

  @override
  void initState() {
    super.initState();
    _database.databaseURL =
    'https://beyond-borders-457415-default-rtdb.asia-southeast1.firebasedatabase.app/';
    _postsRef = _database.ref().child('posts');
    _usersRef = _database.ref().child('users');
    _fetchCurrentUserData();
    _fetchPosts();
  }

  Future<void> _fetchCurrentUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
        if (userData != null) {
          setState(() {
            _currentUserFullName = userData['fullName'] ?? 'User';
            _currentUserProfileImage = userData['profileImage'] ?? '';
          });
        }
      }
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading posts: $error')),
      );
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxWidth: 1200,
          maxHeight: 1200
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        print("Image picked successfully: ${pickedFile.path}");
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        print("Photo taken successfully: ${pickedFile.path}");
      }
    } catch (e) {
      print("Error taking photo: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take photo: $e')),
      );
    }
  }

  Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Read the file
    final image = img.decodeImage(await file.readAsBytes());
    if (image == null) {
      return file; // Return original if decoding fails
    }

    // Resize and compress
    final compressedImage = img.encodeJpg(image, quality: 85);

    // Save to new file
    final result = await File(targetPath).writeAsBytes(compressedImage);

    return result;
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
          setState(() {
            _locationController.text = "";
          });
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
    if (_postTextController.text.trim().isEmpty && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some text or an image to your post')),
      );
      return;
    }

    setState(() {
      _isPostingLoading = true;
      _uploadProgress = 0.0;
    });

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      // Get the latest user data
      DataSnapshot userSnapshot = await _usersRef.child(currentUser.uid).get();

      String fullName = _currentUserFullName;
      String userProfileImage = _currentUserProfileImage;

      if (userSnapshot.exists && userSnapshot.value != null) {
        Map<dynamic, dynamic>? userData = userSnapshot.value as Map?;
        if (userData != null) {
          fullName = userData['fullName'] ?? fullName;
          userProfileImage = userData['profileImage'] ?? userProfileImage;
        }
      }

      String? imageUrl;

      if (_imageFile != null) {
        try {
          // Compress image before uploading
          File compressedImage = await compressImage(_imageFile!);

          String fileName =
              'posts/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference storageRef = _storage.ref().child(fileName);

          // Track upload progress
          UploadTask uploadTask = storageRef.putFile(compressedImage);

          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            double progress = snapshot.bytesTransferred / snapshot.totalBytes;
            setState(() {
              _uploadProgress = progress;
            });
          });

          // Wait for upload to complete
          await uploadTask;
          imageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          print('Error uploading image: $e');
          // Continue without image if upload fails
        }
      }

      Map<String, dynamic> postData = {
        'userId': currentUser.uid,
        'fullName': fullName,
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
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to like posts')),
        );
        return;
      }

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

  Future<void> _deletePost(Post post) async {
    // Show confirmation dialog before deleting
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;

    // If user didn't confirm, return
    if (!confirmDelete) return;

    try {
      // Check if user is the post owner
      User? currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != post.userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only delete your own posts')),
        );
        return;
      }

      // Delete image if exists
      if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
        try {
          // Extract the path from the URL
          Reference imageRef = _storage.refFromURL(post.imageUrl!);
          await imageRef.delete();
        } catch (e) {
          print('Error deleting image: $e');
          // Continue with post deletion even if image deletion fails
        }
      }

      // Delete post from database
      await _postsRef.child(post.id).remove();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  Future<void> _showImageOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      SizedBox(height: 8),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCreatePostPopup() {
    // Reset state before showing dialog
    _imageFile = null;
    _postTextController.clear();
    _locationController.clear();

    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                backgroundColor: Colors.white,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile and input section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile avatar
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: _currentUserProfileImage.isNotEmpty
                                ? NetworkImage(_currentUserProfileImage)
                                : null,
                            backgroundColor: Colors.blue,
                            child: _currentUserProfileImage.isEmpty
                                ? const Icon(Icons.person, size: 24, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          // Text input field
                          Expanded(
                            child: TextField(
                              controller: _postTextController,
                              decoration: const InputDecoration(
                                hintText: 'What is up traveler?',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              style: const TextStyle(fontSize: 18),
                              maxLines: 8,
                              minLines: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Location input with rounded border
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _locationController,
                                decoration: const InputDecoration(
                                  hintText: 'Where you at?',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _getCurrentLocation();
                              },
                              child: const Icon(Icons.location_on_outlined),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Image preview if selected
                      if (_imageFile != null)
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _imageFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                shadows: [
                                  Shadow(blurRadius: 3.0, color: Colors.black),
                                ],
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  _imageFile = null;
                                });
                              },
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Upload progress indicator
                      if (_isPostingLoading && _uploadProgress > 0 && _uploadProgress < 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Uploading image: ${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(value: _uploadProgress),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Bottom row with image picker and post button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Image picker button
                          GestureDetector(
                            onTap: () {
                              _showImageOptions().then((_) {
                                // Update dialog state after image is selected
                                setDialogState(() {});
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.image,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                          ),

                          // Loading indicator (center)
                          if (_isPostingLoading && (_uploadProgress == 0 || _uploadProgress == 1))
                            const CircularProgressIndicator(),

                          // Post button
                          ElevatedButton(
                            onPressed: _isPostingLoading ? null : () {
                              _createPost();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? const Center(child: Text('No posts yet. Be the first to share!'))
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
            bool isOwner = _auth.currentUser != null &&
                _auth.currentUser!.uid == post.userId;

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
                      backgroundColor: Colors.blue,
                      child: post.userProfileImage.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      post.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: post.location.isNotEmpty
                        ? Row(
                      children: [
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Expanded(child: Text(post.location, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTimestamp(post.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (isOwner)
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deletePost(post);
                              }
                            },
                          ),
                      ],
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
                    GestureDetector(
                      onTap: () => _viewImage(post.imageUrl!),
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 400,
                        ),
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrl!,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(height: 4),
                                Text('Image load error: $error', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
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
        onPressed: _showCreatePostPopup,
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
  final String fullName;
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
    required this.fullName,
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
      fullName: data['fullName'] ?? 'User',
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