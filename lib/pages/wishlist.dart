import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beyond_borders/components/custom_drawer.dart';

import '../components/custom_appbar.dart';  // Make sure to import your custom drawer

class WishlistPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: buildAppBar(context),
        body: Center(
          child: Text('You must be logged in to see your wishlist.'),
        ),
      );
    }

    return Scaffold(
      appBar: buildAppBar(context),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title for the Wishlist page with your custom styling
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                'Wishlist',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // StreamBuilder to fetch and display the wishlist items
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('wishlist')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Your Wishlist is empty!',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }

                final wishlistItems = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true, // Prevents ListView from taking up more space than needed
                  itemCount: wishlistItems.length,
                  itemBuilder: (context, index) {
                    var item = wishlistItems[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: Image.asset(
                          item['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item['name']),
                        subtitle: Text(item['country']),
                        trailing: Icon(Icons.favorite, color: Colors.red),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
