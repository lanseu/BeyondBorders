import 'package:flutter/material.dart';

import 'destination_details.dart';

class AllPopularDestinations extends StatefulWidget {
  final List<Map<String, dynamic>> popularDestinations;

  const AllPopularDestinations({
    Key? key,
    required this.popularDestinations,
  }) : super(key: key);

  @override
  State<AllPopularDestinations> createState() => _AllPopularDestinationsState();
}

class _AllPopularDestinationsState extends State<AllPopularDestinations> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Popular Destinations',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: widget.popularDestinations.length,
          itemBuilder: (context, index) {
            final destination = widget.popularDestinations[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DestinationDetails(
                      name: destination['name'],
                      country: destination['country'],
                      rating: destination['rating'],
                      image: destination['image'],
                      tags: destination['tags'],
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(destination['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                            width: double.infinity,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  destination['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      destination['country'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      destination['price'],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 16),
                                        const SizedBox(width: 2),
                                        Text(
                                          destination['rating'].toString(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: (destination['tags'] ?? [])
                                      .map<Widget>((tag) => _buildTagChip(tag))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
