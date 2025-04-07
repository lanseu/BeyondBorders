import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:beyond_borders/models/activities.dart';
import 'package:beyond_borders/models/category_model.dart';
import 'package:beyond_borders/models/travel_model.dart';
import 'package:beyond_borders/components/custom_drawer.dart';
import 'package:beyond_borders/components/custom_appbar.dart';
import 'package:beyond_borders/pages/london_destinations.dart';
import 'package:beyond_borders/pages/japan_destinations.dart';

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
  String searchQuery = '';  // Add a variable to store the search query
  bool isAscending = true;  // Add a variable to store the sorting order
  FilterType selectedFilter = FilterType.all;  // Add a variable to store the selected filter type

  // Add filtering logic
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

  // Add sorting logic
  void sortCategories() {
    categories.sort((a, b) => isAscending
        ? a.name.compareTo(b.name)
        : b.name.compareTo(a.name));
  }

  void sortTravelCategories() {
    travelCategories.sort((a, b) => isAscending
        ? a.name.compareTo(b.name)
        : b.name.compareTo(a.name));
  }

  void sortActivities() {
    activities.sort((a, b) => isAscending
        ? a.name.compareTo(b.name)
        : b.name.compareTo(a.name));
  }

  void _getCategoryInfo() {
    categories = CategoryModel.getCategories();
    travelCategories = TravelCategory.getTravelCategories();
    activities = ActivityModel.getActivities();
    sortCategories();
    sortTravelCategories();
    sortActivities();
  }

  @override
  void initState() {
    _getCategoryInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _searchField(),
            SizedBox(height: 40),
            if (selectedFilter == FilterType.all || selectedFilter == FilterType.categories)
              _categoriesSection(),  // Display filtered categories
            if (selectedFilter == FilterType.all || selectedFilter == FilterType.popularDestinations)
              Padding(
                padding: const EdgeInsets.only(top: 40),  // Add spacing
                child: _travelSection(),  // Display filtered travel categories
              ),
            if (selectedFilter == FilterType.all || selectedFilter == FilterType.activities)
              Padding(
                padding: const EdgeInsets.only(top: 40),  // Add spacing
                child: _activitiesSection(),  // Display filtered activities
              ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Categories section with filtered categories
  Column _categoriesSection() {
    var filteredCategories = getFilteredCategories();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Category',
            style: TextStyle(
              color: Color(0xff1D1617),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.separated(
              itemCount: filteredCategories.length,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 20, right: 20),
              separatorBuilder: (context, index) => SizedBox(width: 25),
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: filteredCategories[index].boxColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(filteredCategories[index].iconPath),
                      ),
                      Text(
                        filteredCategories[index].name,
                        style: TextStyle(
                          color: Color(0xff828796),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }

  // Travel section with filtered travel categories
  Column _travelSection() {
    var filteredTravelCategories = getFilteredTravelCategories();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Popular Destination',
            style: TextStyle(
              color: Color(0xff1D1617),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 15),
        SizedBox(
          height: 240,
          child: ListView.separated(
            itemBuilder: (context, index) {
              return Container(
                width: 210,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: filteredTravelCategories[index].boxColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      filteredTravelCategories[index].iconPath,
                      height: 80,
                      width: 80,
                    ),
                    SizedBox(height: 10),
                    Text(
                      filteredTravelCategories[index].name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      filteredTravelCategories[index].destination,
                      style: TextStyle(
                        color: Color(0xff828796),
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      height: 40,
                      width: 130,
                      child: InkWell(
                        onTap: () {
                          if (travelCategories[index].name == 'London Bridge') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LondonDestinations(),
                              ),
                            );
                          } else if (travelCategories[index].name ==
                              'Japanese Shrine') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JapanDestinations(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                filteredTravelCategories[index].viewIsSelected
                                    ? Color(0xff64B6FF)
                                    : Colors.transparent,
                                filteredTravelCategories[index].viewIsSelected
                                    ? Color(0xff64B6FF)
                                    : Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: Text(
                              'View',
                              style: TextStyle(
                                color: filteredTravelCategories[index].viewIsSelected
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            itemCount: filteredTravelCategories.length,
            separatorBuilder: (context, index) => SizedBox(width: 25),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
      ],
    );
  }

  // Activities section with filtered activities
  Column _activitiesSection() {
    var filteredActivities = getFilteredActivities();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0, left: 20, right: 20),
          child: Text(
            'Activities',
            style: TextStyle(
              color: Color(0xff1D1617),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 15),
        ListView.separated(
          shrinkWrap: true, // Set shrinkWrap to true
          physics: NeverScrollableScrollPhysics(), // Disable inner scrolling
          itemBuilder: (context, index) {
            return Container(
              height: 115,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff1D1617).withOpacity(0.07),
                      spreadRadius: 0.0,
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    )
                  ]),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      filteredActivities[index].iconPath,
                      height: 80,
                      width: 80,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filteredActivities[index].name,
                            style: TextStyle(
                              color: Color(0xff1D1617),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            filteredActivities[index].description,
                            style: TextStyle(
                              color: Color(0xff828796),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 20),
          itemCount: filteredActivities.length,
        ),
      ],
    );
  }

  // Search field with onChanged to update the search query
  Container _searchField() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(top: 40, left: 20, right: 20),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color(0xff1D1617).withOpacity(0.3),
          spreadRadius: 0.0,
          blurRadius: 40,
          offset: const Offset(0, 3),
        )
      ]),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xffF7F8F8),
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Color(0xff828796),
            fontSize: 15,
          ),
          contentPadding: EdgeInsets.all(15),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset("assets/icons/search.svg"),
          ),
          suffixIcon: SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                VerticalDivider(
                  color: Color(0xffddddada),
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
                PopupMenuButton<String>(
                  icon: SvgPicture.asset("assets/icons/settings.svg"),
                  onSelected: (value) {
                    setState(() {
                      if (value == 'A-Z' || value == 'Z-A') {
                        isAscending = value == 'A-Z';
                        sortCategories();
                        sortTravelCategories();
                        sortActivities();
                      } else if (value == 'All') {
                        selectedFilter = FilterType.all;
                      } else if (value == 'Categories') {
                        selectedFilter = FilterType.categories;
                      } else if (value == 'Popular Destinations') {
                        selectedFilter = FilterType.popularDestinations;
                      } else if (value == 'Activities') {
                        selectedFilter = FilterType.activities;
                      }
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return {'A-Z', 'Z-A', 'All', 'Categories', 'Popular Destinations', 'Activities'}
                        .map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

