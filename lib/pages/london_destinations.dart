import 'package:flutter/material.dart';
import 'package:beyond_borders/pages/custom_appbar.dart';
import 'package:beyond_borders/pages/custom_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LondonDestinations extends StatefulWidget {
  const LondonDestinations({super.key});

  @override
  _LondonDestinationsState createState() => _LondonDestinationsState();
}

class _LondonDestinationsState extends State<LondonDestinations> {
  bool isFavourite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, showBackButton: true),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(),
            _buildDestinationDetails(),
            _buildInfoCards(),
            _buildAttractionsList(),
            _buildGoNowButton(),
          ],
        ),
      ),
    );
  }

  // Header Image with heart/favourite icon
  Widget _buildHeaderImage() {
    return Container(
        margin: EdgeInsets.only(top: 20),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/london_bridge_header.jpg',
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
                    isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border_outlined,
                    color: Colors.red,
                    size: 25,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavourite = !isFavourite;
                    });
                  },
                ),
              ),
            ),
          ],
        ));
  }

  // Destination Name and Location with Rating
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
                'London, England',
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
                      '4.5',
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
                'United Kingdom',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          )
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
          _infoCard('Best Time', 'March - May',
              'assets/icons/destinations_detail_clock.svg'),
          _infoCard('Ideal For', 'Family, Friends',
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

  Widget _buildAttractionsList() {
    final attractions = [
      'Big Ben',
      'London Eye',
      'Tower Bridge',
      'Buckingham Palace',
      'British Museum'
    ];
    return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Popular Attractions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...attractions.map((attraction) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(128),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 0.0),
                    onPressed: () {},
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            attraction,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                )))
          ],
        ));
  }

  Widget _buildGoNowButton() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[200],
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            onPressed: () {},
            child: Text(
              'Go Now',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ));
  }
}
