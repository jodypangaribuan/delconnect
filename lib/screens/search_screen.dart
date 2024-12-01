import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import 'package:iconsax/iconsax.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final bool _isScrolled = false;
  bool _isSearching = false;
  int _selectedCategory = 0;
  final int _currentIndex = 1;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Iconsax.global, 'label': 'Semua'},
    {'icon': Iconsax.profile_2user, 'label': 'Teman'},
    {'icon': Iconsax.book, 'label': 'Materi'},
    {'icon': Iconsax.calendar, 'label': 'Event'},
    {'icon': Iconsax.teacher, 'label': 'Dosen'},
    {'icon': Iconsax.building, 'label': 'Gedung'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildSearchHeader(isDark),
                _buildCategories(isDark),
                Expanded(
                  child: _isSearching
                      ? _buildSearchResults(isDark)
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Jelajahi',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              _buildInteractiveGrid(isDark),
                              const SizedBox(height: 24),
                              _buildTrendingTopics(isDark),
                              const SizedBox(height: 24),
                              _buildLocationsGrid(isDark),
                              const SizedBox(
                                  height: kBottomNavigationBarHeight),
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
  }

  Widget _buildSearchHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Iconsax.arrow_left,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              // No need to update navigation state as we're just popping
            },
          ),
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.search_normal,
                    color:
                        (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _isSearching = value.isNotEmpty),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari postingan, teman, atau topik...',
                        hintStyle: TextStyle(
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(bool isDark) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 16),
              width: 80,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue
                    : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _categories[index]['icon'],
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.7),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _categories[index]['label'],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    // Implementation for search results
    return _buildMasonryGrid(isDark);
  }

  Widget _buildInteractiveGrid(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: 10,
        itemBuilder: (context, index) => _buildInteractiveItem(isDark, index),
      ),
    );
  }

  Widget _buildInteractiveItem(bool isDark, int index) {
    final topics = [
      {'icon': Iconsax.book_1, 'label': 'Materi Kuliah'},
      {'icon': Iconsax.people, 'label': 'Teman Sekelas'},
      {'icon': Iconsax.calendar_1, 'label': 'Event Kampus'},
      {'icon': Iconsax.teacher, 'label': 'Info Dosen'},
      {'icon': Iconsax.building_4, 'label': 'Gedung & Fasilitas'},
      {'icon': Iconsax.activity, 'label': 'Kegiatan'},
      {'icon': Iconsax.chart, 'label': 'Akademik'},
      {'icon': Iconsax.bookmark, 'label': 'Tersimpan'},
      {'icon': Iconsax.trend_up, 'label': 'Trending'},
      {'icon': Iconsax.flash, 'label': 'Quick Links'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                topics[index]['icon'] as IconData,
                size: 32,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 12),
              Text(
                topics[index]['label'] as String,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedContent(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Trending Topics', isDark),
          _buildTrendingTopics(isDark),
          _buildSectionTitle('Popular Locations', isDark),
          _buildLocationsGrid(isDark),
          _buildSectionTitle('Recent Events', isDark),
          _buildEventsList(isDark),
        ],
      ),
    );
  }

  Widget _buildMasonryGrid(bool isDark) {
    // Implementation for masonry grid
    return Center(
      child: Text(
        'Masonry Grid Placeholder',
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTrendingTopics(bool isDark) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Example count
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'Trending Topic ${index + 1}',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4, // Example count
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              'Location ${index + 1}',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3, // Example count
      itemBuilder: (context, index) {
        return Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              'Event ${index + 1}',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}
