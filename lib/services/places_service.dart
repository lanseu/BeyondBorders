import 'dart:convert';
import 'package:http/http.dart' as http;

class Review {
  final String authorName;
  final double rating;
  final String text;
  final String relativeTime;
  final String? profilePhotoUrl;

  Review({
    required this.authorName,
    required this.rating,
    required this.text,
    required this.relativeTime,
    this.profilePhotoUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['author_name'] ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      text: json['text'] ?? 'No review text',
      relativeTime: json['relative_time_description'] ?? '',
      profilePhotoUrl: json['profile_photo_url'],
    );
  }
}

class PlacePhoto {
  final String photoReference;
  final int height;
  final int width;
  final List<String>? attributions;

  PlacePhoto({
    required this.photoReference,
    required this.height,
    required this.width,
    this.attributions,
  });

  factory PlacePhoto.fromJson(Map<String, dynamic> json) {
    List<String> attributionList = [];
    if (json['html_attributions'] != null) {
      attributionList = (json['html_attributions'] as List)
          .map((attr) => attr.toString())
          .toList();
    }

    return PlacePhoto(
      photoReference: json['photo_reference'] ?? '',
      height: json['height'] ?? 0,
      width: json['width'] ?? 0,
      attributions: attributionList.isNotEmpty ? attributionList : null,
    );
  }
}

class Place {
  final String placeId;
  final String name;
  final String? address;
  final double? rating;
  final List<PlacePhoto>? photos;
  final List<Review>? reviews;

  Place({
    required this.placeId,
    required this.name,
    this.address,
    this.rating,
    this.photos,
    this.reviews,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // Process reviews if available
    List<Review>? reviewsList;
    if (json['reviews'] != null) {
      reviewsList = (json['reviews'] as List)
          .map((reviewJson) => Review.fromJson(reviewJson))
          .toList();
    }

    // Process photos if available
    List<PlacePhoto>? photosList;
    if (json['photos'] != null) {
      photosList = (json['photos'] as List)
          .map((photoJson) => PlacePhoto.fromJson(photoJson))
          .toList();
    }

    return Place(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['formatted_address'],
      rating: (json['rating'] as num?)?.toDouble(),
      photos: photosList,
      reviews: reviewsList,
    );
  }
}

class PlacesService {
  final String apiKey;
  PlacesService(this.apiKey);

  Future<List<Place>> searchAttractions(String name) async {
    final query = Uri.encodeComponent("top tourist attractions in $name");
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&type=tourist_attraction&key=$apiKey';

    print("API URL: $url");

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load places');
    }
    final data = json.decode(response.body);
    if (data['status'] != 'OK') {
      print("API Error: ${data['status']}");
      print("Error Message: ${data['error_message'] ?? 'No error message'}");
      throw Exception(
          'API error: ${data['status']} - ${data['error_message'] ?? "No error message"}');
    }
    final results = data['results'] as List<dynamic>;
    return results.map((json) => Place.fromJson(json)).toList();
  }

  Future<Place> getPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,formatted_address,rating,photos,reviews&key=$apiKey';

    print("Details API URL: $url");

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load place details');
    }

    final data = json.decode(response.body);
    if (data['status'] != 'OK') {
      print("API Error: ${data['status']}");
      print("Error Message: ${data['error_message'] ?? 'No error message'}");
      throw Exception(
          'API error: ${data['status']} - ${data['error_message'] ?? "No error message"}');
    }

    return Place.fromJson(data['result']);
  }

  Future<List<Review>> getPlaceReviews(String placeId) async {
    try {
      Place placeDetails = await getPlaceDetails(placeId);
      return placeDetails.reviews ?? [];
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
  }

  // Get photo URL for a photo reference
  String getPhotoUrl(String photoReference, {int maxWidth = 800}) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
  }

  // Helper method to get top attractions with details (reviews and photos)
  Future<List<Place>> getTopAttractionsWithDetails(String country, {int limit = 5}) async {
    try {
      // Get top attractions
      List<Place> attractions = await searchAttractions(country);

      // Sort by rating if available
      attractions.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

      // Take top attractions
      List<Place> topAttractions = attractions.take(limit).toList();

      // Fetch details with reviews and photos for each
      List<Place> attractionsWithDetails = [];
      for (var attraction in topAttractions) {
        if (attraction.placeId.isNotEmpty) {
          try {
            Place detailedPlace = await getPlaceDetails(attraction.placeId);
            attractionsWithDetails.add(detailedPlace);
          } catch (e) {
            print("Error getting details for ${attraction.name}: $e");
            // Add the original attraction without details
            attractionsWithDetails.add(attraction);
          }
        }
      }

      return attractionsWithDetails;
    } catch (e) {
      print("Error getting attractions with details: $e");
      return [];
    }
  }
}