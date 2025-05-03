import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/places_service.dart';

class ReviewPanel extends StatefulWidget {
  final String name;

  const ReviewPanel({Key? key, required this.name}) : super(key: key);

  @override
  _ReviewPanelState createState() => _ReviewPanelState();
}

class _ReviewPanelState extends State<ReviewPanel> {
  late final PlacesService _placesService;
  late Future<List<Place>> _placesFuture;
  int _selectedAttractionIndex = 0;

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      _placesFuture = Future.error('API key not found. Please check your .env file.');
    } else {
      _placesService = PlacesService(apiKey);
      _placesFuture = _placesService.getTopAttractionsWithDetails(widget.name, limit: 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reviews',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildAttractionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttractionsList() {
    return FutureBuilder<List<Place>>(
      future: _placesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading reviews: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No review data found for ${widget.name}'),
          );
        } else {
          List<Place> places = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal list of attractions to select
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(places[index].name),
                        selected: _selectedAttractionIndex == index,
                        onSelected: (selected) {
                          setState(() {
                            _selectedAttractionIndex = index;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),

              // Display attraction info
              _buildAttractionInfo(places[_selectedAttractionIndex]),

              // Display reviews for selected attraction
              _buildReviewsList(places[_selectedAttractionIndex]),
            ],
          );
        }
      },
    );
  }

  Widget _buildAttractionInfo(Place place) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (place.address != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  place.address!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            SizedBox(height: 8),
            Row(
              children: [
                if (place.rating != null) ...[
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text(
                    '${place.rating!.toStringAsFixed(1)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'based on ${place.reviews?.length ?? 0} reviews',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ] else
                  Text('No ratings available'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(Place place) {
    if (place.reviews == null || place.reviews!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('No reviews available for this attraction')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: place.reviews!.length,
      itemBuilder: (context, index) {
        Review review = place.reviews![index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: review.profilePhotoUrl != null
                          ? NetworkImage(review.profilePhotoUrl!)
                          : null,
                      child: review.profilePhotoUrl == null
                          ? Icon(Icons.person)
                          : null,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.authorName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            review.relativeTime,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        SizedBox(width: 4),
                        Text(
                          review.rating.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(review.text),
              ],
            ),
          ),
        );
      },
    );
  }
}