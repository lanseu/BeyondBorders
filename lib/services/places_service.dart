import 'dart:convert';
import 'package:http/http.dart' as http;

class Place {
  final String name;
  final String? address;
  final double? rating;
  final String? photoReference;

  Place({
    required this.name,
    this.address,
    this.rating,
    this.photoReference,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      address: json['formatted_address'],
      rating: (json['rating'] as num?)?.toDouble(),
      photoReference: (json['photos'] != null && (json['photos'] as List).isNotEmpty)
          ? json['photos'][0]['photo_reference']
          : null,
    );
  }
}

class PlacesService {
  final String apiKey;
  PlacesService(this.apiKey);

  Future<List<Place>> searchAttractions(String country) async {
    final query = Uri.encodeComponent("top tourist attractions in $country");
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&type=tourist_attraction&rankby=prominence&key=$apiKey';

    print("API URL: $url");

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load places');
    }
    final data = json.decode(response.body);
    if (data['status'] != 'OK') {
      print("API Error: ${data['status']}");
      print("Error Message: ${data['error_message']}");
      throw Exception('API error: ${data['status']} - ${data['error_message'] ?? "No error message"}');
    }
    final results = data['results'] as List<dynamic>;
    return results.map((json) => Place.fromJson(json)).toList();
  }
}
