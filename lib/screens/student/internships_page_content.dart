import 'package:flutter/material.dart';
import 'package:hackifm/services/api_service.dart';
import 'package:hackifm/models/comprehensive_models.dart';
import 'package:hackifm/screens/student/internship_detail_screen.dart';

class InternshipsPageContent extends StatefulWidget {
  const InternshipsPageContent({super.key});

  @override
  State<InternshipsPageContent> createState() => _InternshipsPageContentState();
}

class _InternshipsPageContentState extends State<InternshipsPageContent> {
  final ApiService _apiService = ApiService();
  List<Internship> _internships = [];
  List<Internship> _filteredInternships = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Remote', 'Tech', 'Full Time'];

  @override
  void initState() {
    super.initState();
    _loadInternships();
  }

  Future<void> _loadInternships() async {
    try {
      final data = await _apiService.getInternships();
      setState(() {
        _internships = (data as List)
            .map((json) => Internship.fromJson(json as Map<String, dynamic>))
            .toList();
        _filteredInternships = _internships;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading internships: $e')),
        );
      }
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredInternships = _internships;
      } else if (filter == 'Remote') {
        _filteredInternships = _internships
            .where((i) => i.internshipType?.toLowerCase() == 'remote')
            .toList();
      } else if (filter == 'Tech') {
        _filteredInternships = _internships
            .where((i) => i.category?.toLowerCase().contains('tech') ?? false)
            .toList();
      } else if (filter == 'Full Time') {
        _filteredInternships = _internships
            .where((i) => i.duration?.toLowerCase().contains('full') ?? false)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final horizontalPadding = isDesktop ? 40.0 : (isTablet ? 32.0 : 20.0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Internships',
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: screenWidth < 600
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: screenWidth < 600,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filters
                Container(
                  height: isDesktop ? 70 : 60,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;
                      return Padding(
                        padding: EdgeInsets.only(right: isDesktop ? 16 : 12),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) => _applyFilter(filter),
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF6366F1),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: isDesktop ? 16 : 15,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 24 : 20,
                            vertical: isDesktop ? 14 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF6366F1)
                                  : Colors.grey[300]!,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Internships list - Responsive Grid/List
                Expanded(
                  child: _filteredInternships.isEmpty
                      ? Center(
                          child: Text(
                            'No internships found',
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isDesktop ? 1400 : double.infinity,
                            ),
                            child: isDesktop || isTablet
                                ? GridView.builder(
                                    padding: EdgeInsets.all(horizontalPadding),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: isDesktop ? 2 : 1,
                                          mainAxisSpacing: isDesktop ? 24 : 20,
                                          crossAxisSpacing: isDesktop ? 24 : 20,
                                          childAspectRatio: isDesktop
                                              ? 1.8
                                              : 2.2,
                                        ),
                                    itemCount: _filteredInternships.length,
                                    itemBuilder: (context, index) {
                                      return _buildInternshipCard(
                                        _filteredInternships[index],
                                        isDesktop,
                                        isTablet,
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.all(horizontalPadding),
                                    itemCount: _filteredInternships.length,
                                    itemBuilder: (context, index) {
                                      return _buildInternshipCard(
                                        _filteredInternships[index],
                                        isDesktop,
                                        isTablet,
                                      );
                                    },
                                  ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildInternshipCard(
    Internship internship,
    bool isDesktop,
    bool isTablet,
  ) {
    // Calculate time remaining
    String timeText = '3 months';
    if (internship.applicationDeadline != null) {
      try {
        final now = DateTime.now();
        final deadline = DateTime.parse(internship.applicationDeadline!);
        final difference = deadline.difference(now);

        if (difference.inDays > 30) {
          timeText = '${(difference.inDays / 30).floor()} months';
        } else if (difference.inDays > 0) {
          timeText = '${difference.inDays} days';
        } else {
          timeText = 'Expired';
        }
      } catch (e) {
        timeText = '3 months';
      }
    }

    final cardPadding = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);
    final titleSize = isDesktop ? 22.0 : (isTablet ? 21.0 : 20.0);
    final companySize = isDesktop ? 17.0 : 16.0;
    final descSize = isDesktop ? 15.0 : 14.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InternshipDetailScreen(internship: internship),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isDesktop || isTablet ? 0 : 16),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    internship.title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  timeText,
                  style: TextStyle(fontSize: descSize, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 10 : 8),
            Text(
              internship.company,
              style: TextStyle(
                fontSize: companySize,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isDesktop ? 14 : 12),
            Text(
              internship.description ?? '',
              style: TextStyle(
                fontSize: descSize,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: isDesktop ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isDesktop ? 18 : 16),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16 : 14,
                    vertical: isDesktop ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    internship.internshipType ?? 'Remote',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InternshipDetailScreen(internship: internship),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 28 : 24,
                      vertical: isDesktop ? 14 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
