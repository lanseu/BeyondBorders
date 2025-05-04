import 'package:beyond_borders/components/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../components/custom_appbar.dart';
import '../components/destination_panels/overview_panel.dart';
import '../components/destination_panels/photos_panel.dart';
import '../components/destination_panels/review_panel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DestinationDetails extends StatefulWidget {
  final String name;
  final String country;
  final double rating;
  final String image;
  final String? bestTime;
  final String? idealFor;
  final List<String>? tags;

  const DestinationDetails({
    super.key,
    required this.name,
    required this.country,
    required this.rating,
    required this.image,
    this.bestTime = 'March - May',
    this.idealFor = 'Couple, Friends',
    this.tags,
  });

  @override
  _DestinationDetailsState createState() => _DestinationDetailsState();
}

class _DestinationDetailsState extends State<DestinationDetails> {

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final wishlistRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(widget.name);

      final snapshot = await wishlistRef.get();
      if (snapshot.exists) {
        setState(() {
          isFavourite = true;
        });
      }
    }
  }


  bool isFavourite = false;

  Widget _buildTagChip(String tag) {
    final Map<String, Map<String, Color>> colorMapping = {
      'Hiking': {'background': Colors.green.shade100, 'text': Colors.green.shade800},
      'Photography': {'background': Colors.pink.shade100, 'text': Colors.pink.shade800},
      'Culture': {'background': Colors.purple.shade100, 'text': Colors.purple.shade800},
      'Food': {'background': Colors.red.shade100, 'text': Colors.red.shade800},
      'Beach': {'background': Colors.yellow.shade100, 'text': Colors.yellow.shade800},
      'Adventure': {'background': Colors.orange.shade100, 'text': Colors.orange.shade800},
      'Relaxation': {'background': Colors.teal.shade100, 'text': Colors.teal.shade800},
      'History': {'background': Colors.brown.shade300, 'text': Colors.brown.shade800},
    };

    final colors = colorMapping[tag] ?? {'background': Colors.grey.shade200, 'text': Colors.grey.shade800};

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: colors['text'],
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: buildAppBar(context, showBackButton: true),
        drawer: CustomDrawer(),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderImage(),
                    _buildDestinationDetails(),
                    _buildInfoCards(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ];
          },
          body: Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        Expanded(child: OverviewPanel(name: widget.name)),
                        _buildBookNowButton(),
                      ],
                    ),
                    Column(
                      children: [
                        Expanded(child: ReviewPanel(name: widget.name)),
                        _buildBookNowButton(),
                      ],
                    ),
                    Column(
                      children: [
                        Expanded(child: PhotosPanel(name: widget.name)),
                        _buildBookNowButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Stack(
      children: [
        Image.asset(
          widget.image,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
        ),
        Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: IconButton(
                icon: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border_outlined,
                  color: Colors.red,
                  size: 25,
                ),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final wishlistRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('wishlist')
                        .doc(widget.name); // using destination name as ID (better if you have a unique ID)

                    final snapshot = await wishlistRef.get();

                    if (snapshot.exists) {
                      // Already favorited, so remove it
                      await wishlistRef.delete();
                      setState(() {
                        isFavourite = false;
                      });
                    } else {
                      // Not favorited, so add it
                      await wishlistRef.set({
                        'name': widget.name,
                        'country': widget.country,
                        'rating': widget.rating,
                        'image': widget.image,
                        'bestTime': widget.bestTime,
                        'idealFor': widget.idealFor,
                      });
                      setState(() {
                        isFavourite = true;
                      });
                    }
                  }
                },

              ),
            )),
      ],
    );
  }

  Widget _buildDestinationDetails() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(74, 144, 226, 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_border, color: Colors.black, size: 25),
                    SizedBox(width: 5),
                    Text(
                      widget.rating.toString(),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(
                Icons.place_outlined,
                color: Colors.grey[700],
                size: 25,
              ),
              Text(
                widget.country,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (widget.tags != null && widget.tags!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: widget.tags!
                  .map((tag) => _buildTagChip(tag))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _infoCard('Best Time', widget.bestTime ?? 'March - May',
              'assets/icons/destinations_detail_clock.svg'),
          _infoCard('Ideal For', widget.idealFor ?? 'Couple, Friends',
              'assets/icons/destinations_detail_family.svg'),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, String svgPath) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(128),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 30,
              height: 30,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.start),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        tabs: [
          Tab(text: 'Overview'),
          Tab(text: 'Reviews'),
          Tab(text: 'Photos'),
        ],
      ),
    );
  }

  Widget _buildBookNowButton() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            onPressed: () {},
            child: Text(
              'Book Now',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ));
  }
}
