import 'dart:async';
import 'package:flutter/material.dart';
import 'package:beyond_borders/models/activities.dart';
import 'package:beyond_borders/models/category_model.dart';
import 'package:beyond_borders/models/travel_model.dart';
import 'package:beyond_borders/components/custom_drawer.dart';
import 'package:beyond_borders/components/custom_appbar.dart';

import 'all_popular_destinations.dart';
import 'destination_details.dart';

enum FilterType { all, categories, popularDestinations, activities }

class Destination extends StatefulWidget {
  const Destination({super.key});

  @override
  State<Destination> createState() => _DestinationState();
}

class _DestinationState extends State<Destination> {
  List<CategoryModel> categories = [];
  List<TravelCategory> travelCategories = [];
  List<ActivityModel> activities = [];
  String searchQuery = '';
  bool isAscending = true;
  FilterType selectedFilter = FilterType.all;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentFeaturedIndex = 0;
  Timer? _carouselTimer;
  final Set<String> _selectedFilters = {}; // Track selected filters
  List<Map<String, dynamic>> filteredDestinations = [];
  bool showSearchResults = false; // Control when to show search results
  final TextEditingController _searchController = TextEditingController();

  void _startAutoScroll() {
    _carouselTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.round() + 1;
        if (nextPage >= featuredDestinations.length) {
          nextPage = 0; // Loop back to first
        }
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _applyFilters() {
    setState(() {
      filteredDestinations = popularDestinations.where((destination) {
        final tags = (destination['tags'] ?? []).toSet();
        final bestTime = destination['bestTime']?.toLowerCase() ?? '';
        final rating = destination['rating'];
        final matchesTags = _selectedFilters.isEmpty || _selectedFilters.any(tags.contains);
        final matchesSeason = _selectedFilters.any((filter) {
          if (filter == 'Spring') {
            return bestTime.contains('march') || bestTime.contains('april') || bestTime.contains('may');
          } else if (filter == 'Summer') {
            return bestTime.contains('june') || bestTime.contains('july') || bestTime.contains('august');
          } else if (filter == 'Fall') {
            return bestTime.contains('september') || bestTime.contains('october') || bestTime.contains('november');
          } else if (filter == 'Winter') {
            return bestTime.contains('december') || bestTime.contains('january') || bestTime.contains('february');
          }
          return false;
        });
        final matchesRating = _selectedFilters.any((filter) {
          if (filter.endsWith('star') || filter.endsWith('stars')) {
            final star = int.tryParse(filter.split(' ')[0]) ?? 0;
            return rating >= star && rating < star + 1; // Match ratings within the range
          }
          return false;
        });
        return matchesTags || matchesSeason || matchesRating;
      }).toList();
      showSearchResults = true; // Show filtered results
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedFilters.clear();
      filteredDestinations = popularDestinations; // Reset to show all destinations
      showSearchResults = false; // Reset search results
    });
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filters',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Refine your search',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Activities',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _filterChip('Hiking', setState),
                          _filterChip('Photography', setState),
                          _filterChip('Culture', setState),
                          _filterChip('Food', setState),
                          _filterChip('Beach', setState),
                          _filterChip('Adventure', setState),
                          _filterChip('Relaxation', setState),
                          _filterChip('History', setState),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Best Season',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _filterChip('Spring', setState),
                          _filterChip('Summer', setState),
                          _filterChip('Fall', setState),
                          _filterChip('Winter', setState),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Rating',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _filterChip('1 star', setState),
                          _filterChip('2 stars', setState),
                          _filterChip('3 stars', setState),
                          _filterChip('4 stars', setState),
                          _filterChip('5 stars', setState),
                        ],
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue,
                                side: BorderSide(color: Colors.transparent),
                              ),
                              onPressed: () {
                                _clearFilters(); // Clear filters and reset results
                                Navigator.pop(context); // Close the modal
                              },
                              child: Text(
                                'Clear All',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.transparent),
                              ),
                              onPressed: () {
                                _applyFilters(); // Apply filters when "Apply Filters" is clicked
                                Navigator.pop(context); // Close the modal
                              },
                              child: Text(
                                'Apply Filters',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterChip(String label, void Function(void Function()) setState) {
    final Map<String, Map<String, Color>> colorMapping = {
      'Hiking': {'border': Colors.green.shade100, 'text': Colors.green.shade800},
      'Photography': {'border': Colors.pink.shade100, 'text': Colors.pink.shade800},
      'Culture': {'border': Colors.purple.shade100, 'text': Colors.purple.shade800},
      'Food': {'border': Colors.red.shade100, 'text': Colors.red.shade800},
      'Beach': {'border': Colors.yellow.shade100, 'text': Colors.yellow.shade800},
      'Adventure': {'border': Colors.orange.shade100, 'text': Colors.orange.shade800},
      'Relaxation': {'border': Colors.teal.shade100, 'text': Colors.teal.shade800},
      'History': {'border': Colors.brown.shade300, 'text': Colors.brown.shade800},
      'Spring': {'border': Colors.green.shade200, 'text': Colors.green.shade900},
      'Summer': {'border': Colors.yellow.shade200, 'text': Colors.yellow.shade900},
      'Fall': {'border': Colors.orange.shade200, 'text': Colors.orange.shade900},
      'Winter': {'border': Colors.blue.shade200, 'text': Colors.blue.shade900},
      '1 star': {'border': Colors.blue.shade100, 'text': Colors.blue.shade800},
      '2 stars': {'border': Colors.blue.shade100, 'text': Colors.blue.shade800},
      '3 stars': {'border': Colors.blue.shade100, 'text': Colors.blue.shade800},
      '4 stars': {'border': Colors.blue.shade100, 'text': Colors.blue.shade800},
      '5 stars': {'border': Colors.blue.shade100, 'text': Colors.blue.shade800},
    };

    final colors = colorMapping[label] ?? {'border': Color(0xFFD6D6D6), 'text': Color(0xFF6E6E6E)};
    final isSelected = _selectedFilters.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedFilters.remove(label);
          } else {
            _selectedFilters.add(label);
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? colors['border'] : Color(0xFFD6D6D6),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? colors['text'] : Color(0xFF6E6E6E)),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> featuredDestinations = [
    {
      'image': 'assets/images/paris.jpg',
      'name': 'Paris',
      'description': 'The city of lights and romance',
      'days': '4-5 days',
      'rating': 4.8,
      'tags': ['Culture', 'Food'],
    },
    {
      'image': 'assets/images/tokyo.jpg',
      'name': 'Tokyo',
      'description': 'A bustling city blending tradition and technology',
      'days': '5-7 days',
      'rating': 4.7,
      'tags': ['Culture', 'Adventure'],
    },
    {
      'image': 'assets/images/new_york.jpg',
      'name': 'New York',
      'description': 'The city that never sleeps',
      'days': '3-5 days',
      'rating': 4.6,
      'tags': ['Food', 'Relaxation'],
    },
    {
      'image': 'assets/images/rome.jpg',
      'name': 'Rome',
      'description': 'Historic city of ancient wonders',
      'days': '4-6 days',
      'rating': 4.7,
      'tags': ['History', 'Culture'],
    },
    {
      'image': 'assets/images/sydney.jpg',
      'name': 'Sydney',
      'description': 'Home of the iconic Opera House',
      'days': '4-5 days',
      'rating': 4.5,
      'tags': ['Beach', 'Adventure', 'Relaxation'],
    },
    {
      'image': 'assets/images/cape_town.jpg',
      'name': 'Cape Town',
      'description': 'Beautiful coastal city with Table Mountain',
      'days': '5-6 days',
      'rating': 4.6,
      'tags': ['Adventure', 'Relaxation'],
    },
    {
      'image': 'assets/images/dubai.jpg',
      'name': 'Dubai',
      'description': 'City of skyscrapers, shopping, and desert safaris',
      'days': '3-4 days',
      'rating': 4.5,
      'tags': ['Adventure', 'Relaxation'],
    },
    {
      'image': 'assets/images/london.jpeg',
      'name': 'London',
      'description': 'Historic landmarks and modern vibes',
      'days': '4-5 days',
      'rating': 4.7,
      'tags': ['History', 'Culture'],
    },
    {
      'image': 'assets/images/barcelona.jpg',
      'name': 'Barcelona',
      'description': 'Art, architecture, and Mediterranean beaches',
      'days': '4-6 days',
      'rating': 4.6,
      'tags': ['Beach', 'Food'],
    },
    {
      'image': 'assets/images/istanbul.jpg',
      'name': 'Istanbul',
      'description': 'Where East meets West',
      'days': '5-6 days',
      'rating': 4.7,
      'tags': ['Culture', 'History', 'Food'],
    }
  ];

  final List<Map<String, dynamic>> popularDestinations = [
    {
      'image': 'assets/images/bali.jpg',
      'name': 'Bali',
      'country': 'Indonesia',
      'price': '\$80',
      'rating': 4.7,
      'tags': ['Beach', 'Relaxation', 'Adventure'],
      'bestTime': 'March - May', // Added bestTime field
    },
    {
      'image': 'assets/images/santorini.jpg',
      'name': 'Santorini',
      'country': 'Greece',
      'price': '\$350',
      'rating': 4.9,
      'tags': ['Beach', 'Photography', 'Culture'],
      'bestTime': 'June - August', // Added bestTime field
    },
    {
      'image': 'assets/images/banff.jpg',
      'name': 'Banff',
      'country': 'Canada',
      'price': '\$150',
      'rating': 4.8,
      'tags': ['Hiking', 'Adventure'],
      'bestTime': 'September - November', // Added bestTime field
    },
    {
      'image': 'assets/images/amalfi_coast.jpg',
      'name': 'Amalfi Coast',
      'country': 'Italy',
      'price': '\$270',
      'rating': 4.9,
      'tags': ['Beach', 'Culture'],
      'bestTime': 'April - June', // Added bestTime field
    },
    {
      'image': 'assets/images/kyoto.jpg',
      'name': 'Kyoto',
      'country': 'Japan',
      'price': '\$190',
      'rating': 4.7,
      'tags': ['Culture', 'History'],
      'bestTime': 'March - May', // Added bestTime field
    },
    {
      'image': 'assets/images/queenstown.jpg',
      'name': 'Queenstown',
      'country': 'New Zealand',
      'price': '\$210',
      'rating': 4.8,
      'tags': ['Adventure', 'Relaxation'],
    },
    {
      'image': 'assets/images/boracay.png',
      'name': 'Boracay',
      'country': 'Philippines',
      'price': '\$300',
      'rating': 4.6,
      'tags': ['Beach', 'Relaxation'],
    },
    {
      'image': 'assets/images/rio.jpg',
      'name': 'Rio de Janeiro',
      'country': 'Brazil',
      'price': '\$200',
      'rating': 4.6,
      'tags': ['Adventure', 'Culture'],
    },
    {
      'image': 'assets/images/athens.jpg',
      'name': 'Athens',
      'country': 'Greece',
      'price': '\$180',
      'rating': 4.7,
      'tags': ['History', 'Culture'],
    },
    {
      'image': 'assets/images/pyramid.jpg',
      'name': 'Egyptian pyramids',
      'country': 'Egypt',
      'price': '\$170',
      'rating': 4.5,
      'tags': ['History', 'Adventure'],
    },
  ];

  final List<Map<String, dynamic>> nearbyAttractions = [
    {
      'image': 'assets/images/rizal_park.jpg',
      'name': 'Rizal Park',
      'distance': '2.0 km',
      'rating': 4.6,
    },
    {
      'image': 'assets/images/intramuros.jpg',
      'name': 'Intramuros',
      'distance': '2.5 km',
      'rating': 4.7,
    },
  ];

  List<CategoryModel> getFilteredCategories() {
    return categories
        .where((category) => category.name
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
  }

  List<TravelCategory> getFilteredTravelCategories() {
    return travelCategories
        .where((travelCategory) => travelCategory.name
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
  }

  List<ActivityModel> getFilteredActivities() {
    return activities
        .where((activity) => activity.name
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
  }

  void sortCategories() {
    categories.sort((a, b) =>
        isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
  }

  void sortTravelCategories() {
    travelCategories.sort((a, b) =>
        isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
  }

  void sortActivities() {
    activities.sort((a, b) =>
        isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
  }

  void _getCategoryInfo() {
    categories = CategoryModel.getCategories();
    travelCategories = TravelCategory.getTravelCategories();
    activities = ActivityModel.getActivities();
    sortCategories();
    sortTravelCategories();
    sortActivities();
  }

  void _filterDestinations(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredDestinations = popularDestinations;
      } else {
        filteredDestinations = popularDestinations.where((destination) {
          final name = destination['name'].toLowerCase();
          final country = destination['country'].toLowerCase();
          final tags = (destination['tags'] ?? []).join(' ').toLowerCase();
          return name.contains(query.toLowerCase()) ||
              country.contains(query.toLowerCase()) ||
              tags.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _triggerSearch() {
    setState(() {
      showSearchResults = true; // Show search results
    });
  }

  @override
  void initState() {
    super.initState();
    _getCategoryInfo();
    _startAutoScroll();
    filteredDestinations = popularDestinations; // Initialize with all destinations
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchField(),
            SizedBox(height: 20),
            if (showSearchResults) _filteredDestinationsSection(),
            if (!showSearchResults) _featuredDestinationsSection(),
            if (!showSearchResults) SizedBox(height: 20),
            if (!showSearchResults) _popularDestinationsSection(),
            if (!showSearchResults) SizedBox(height: 20),
            if (!showSearchResults) _discoverNearYouSection(),
          ],
        ),
      ),
    );
  }

  // Search field widget
  Container _searchField() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(top: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xff1D1617).withOpacity(0.1),
            spreadRadius: 0.0,
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.centerRight, // Align icons to the right
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              if (value.length <= 50) { // Limit input to 50 characters
                _filterDestinations(value); // Update filtered destinations
                setState(() {
                  showSearchResults = value.isNotEmpty; // Show results if input exists
                });
              } else {
                _searchController.text = value.substring(0, 50); // Trim input
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _searchController.text.length),
                );
              }
            },
            onSubmitted: (value) {
              _triggerSearch(); // Trigger search when "Enter" is pressed
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search destinations...',
              hintStyle: TextStyle(
                color: Color(0xff828796),
                fontSize: 15,
              ),
              contentPadding: EdgeInsets.all(8),
              prefixIcon: Icon(Icons.search, color: Colors.grey), // Left-side search icon
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear(); // Clear the input
                    _filterDestinations(''); // Reset the filtered destinations
                    setState(() {
                      showSearchResults = false; // Hide search results
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.close, color: Colors.grey), // "X" icon
                  ),
                ),
              GestureDetector(
                onTap: () => _showFilterModal(context), // Open filter modal
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.filter_list, color: Colors.grey), // Filtering icon
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filteredDestinationsSection() {
    return filteredDestinations.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'No destinations found.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Results',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0, // Adjusted to make the frame taller
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredDestinations.length,
                  itemBuilder: (context, index) {
                    final destination = filteredDestinations[index];
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
                                  flex: 4, // Increased to make room for up to 3 tags
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
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
                                                    color: Colors.amber,
                                                    size: 16),
                                                const SizedBox(width: 2),
                                                Text(
                                                  destination['rating']
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (destination['tags'] != null)
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: (destination['tags'] ?? [])
                                                .map<Widget>(
                                                    (tag) => _buildTagChip(tag))
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
              ],
            ),
          );
  }

  // Featured Destinations section
  Widget _featuredDestinationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Featured Destinations',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentFeaturedIndex = index;
                  });
                },
                itemCount: featuredDestinations.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      }
                      return Center(
                        child: SizedBox(
                          height: Curves.easeOut.transform(value) * 180,
                          width: Curves.easeOut.transform(value) * 320,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image:
                              AssetImage(featuredDestinations[index]['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                featuredDestinations[index]['days'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  featuredDestinations[index]['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  featuredDestinations[index]['description'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      featuredDestinations[index]['rating']
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: (featuredDestinations[index]['tags'] ?? [])
                                      .map<Widget>((tag) => _buildTagChip(tag))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Left Arrow
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      if (_currentFeaturedIndex > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ),
              // Right Arrow
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white),
                    onPressed: () {
                      if (_currentFeaturedIndex <
                          featuredDestinations.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            featuredDestinations.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentFeaturedIndex == index
                    ? Colors.blue
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
      'Romantic': {'background': Colors.pink.shade50, 'text': Colors.pink.shade600},
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

  // Popular Destinations
  Widget _popularDestinationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Destinations',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Updated View All button with navigation
              GestureDetector(
                onTap: () {
                  // Navigate to All Popular Destinations with a hero animation
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AllPopularDestinations(
                        popularDestinations: popularDestinations,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var begin = const Offset(1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(
                          CurveTween(curve: curve),
                        );
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            // Show only first 2 destinations in main screen
            itemCount:
                popularDestinations.length > 2 ? 2 : popularDestinations.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DestinationDetails(
                        name: popularDestinations[index]['name'],
                        country: popularDestinations[index]['country'],
                        rating: popularDestinations[index]['rating'],
                        image: popularDestinations[index]['image'],
                        tags: popularDestinations[index]['tags'],
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'popular_destination_$index',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      width: 160,
                      margin: EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                image: DecorationImage(
                                  image: AssetImage(
                                      popularDestinations[index]['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Add a gradient overlay for text readability
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.zero,
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  popularDestinations[index]['name'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Colors.grey, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      popularDestinations[index]['country'],
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      popularDestinations[index]['price'],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.star,
                                            color: Colors.amber, size: 16),
                                        SizedBox(width: 2),
                                        Text(
                                          popularDestinations[index]['rating']
                                              .toString(),
                                          style: TextStyle(
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
                                  children: (popularDestinations[index]['tags'] ?? [])
                                      .map<Widget>((tag) => _buildTagChip(tag))
                                      .toList(),
                                ),
                              ],
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
      ],
    );
  }

  // Discover Near You section
  Widget _discoverNearYouSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discover Near You',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '2.5 km radius',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: nearbyAttractions.length,
            itemBuilder: (context, index) {
              return Container(
                width: 150,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          nearbyAttractions[index]['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (nearbyAttractions[index].containsKey('distance'))
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            nearbyAttractions[index]['distance'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nearbyAttractions[index]['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text(
                                nearbyAttractions[index]['rating'].toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
