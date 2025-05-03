import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/places_service.dart';

class OverviewPanel extends StatefulWidget {
  final String name;

  const OverviewPanel({super.key, required this.name});

  @override
  _OverviewPanelState createState() => _OverviewPanelState();
}

class _OverviewPanelState extends State<OverviewPanel> {
  late final PlacesService _placesService;
  late Future<List<Place>> _placesFuture;

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    _placesService = PlacesService(apiKey);
    _placesFuture = _placesService.searchAttractions(widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAttractionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAttractionsList() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular Attractions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          FutureBuilder<List<Place>>(
            future: _placesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading attractions: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No attractions found for ${widget.name}'),
                );
              } else {
                return Column(
                  children: snapshot.data!.map((place) => _buildAttractionItem(place)).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionItem(Place place) {
    return Padding(
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
            elevation: 0.0,
          ),
          onPressed: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (place.address != null)
                        Text(
                          place.address!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (place.rating != null)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              place.rating!.toString(),
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                    ],
                  ),
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
      ),
    );
  }
}