import 'package:beyond_borders/components/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../components/custom_appbar.dart';
import '../components/destination_panels/overview_panel.dart';
import '../components/destination_panels/photos_panel.dart';
import '../components/destination_panels/review_panel.dart';

class DestinationDetails extends StatefulWidget {
  final String name;
  final String country;
  final double rating;
  final String image;
  final String? bestTime;
  final String? idealFor;

  const DestinationDetails({
    super.key,
    required this.name,
    required this.country,
    required this.rating,
    required this.image,
    this.bestTime = 'March - May',
    this.idealFor = 'Couple, Friends',
  });

  @override
  _DestinationDetailsState createState() => _DestinationDetailsState();
}

class _DestinationDetailsState extends State<DestinationDetails> {
  bool isFavourite = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: buildAppBar(context, showBackButton: true),
        drawer: CustomDrawer(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderImage(),
              _buildDestinationDetails(),
              _buildInfoCards(),

              Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(labelColor: Theme.of(context).primaryColor,
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
                ),
              ),
              SizedBox(
                height: 500,
                child: TabBarView(children: [
                  OverviewPanel(country: widget.country),
                  ReviewPanel(),
                  PhotosPanel(),
                ]),
              ),
              _buildBookNowButton()
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
                onPressed: () {
                  setState(() {
                    isFavourite = !isFavourite;
                  });
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
