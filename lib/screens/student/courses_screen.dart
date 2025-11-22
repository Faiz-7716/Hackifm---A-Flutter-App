import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../models/comprehensive_models.dart';
import 'dart:convert';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final ApiService _apiService = ApiService();
  List<CourseModel> courses = [];
  bool isLoading = true;

  String? selectedLevel;
  String? selectedCategory;
  bool? selectedIsPaid;

  final List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> categories = [
    'Web Dev',
    'Data Science',
    'AI/ML',
    'Mobile Dev',
    'Cloud Computing',
  ];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => isLoading = true);

    final result = await _apiService.getCourses(
      level: selectedLevel,
      category: selectedCategory,
      isPaid: selectedIsPaid,
    );

    if (result['success']) {
      setState(() {
        courses = (result['courses'] as List)
            .map((c) => CourseModel.fromJson(c))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error loading courses')),
        );
      }
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Level',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Wrap(
              spacing: 8,
              children: levels
                  .map(
                    (level) => FilterChip(
                      label: Text(level),
                      selected: selectedLevel == level,
                      onSelected: (selected) {
                        setState(() {
                          selectedLevel = selected ? level : null;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            const Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Wrap(
              spacing: 8,
              children: categories
                  .map(
                    (cat) => FilterChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = selected ? cat : null;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            const Text(
              'Price',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Free'),
                  selected: selectedIsPaid == false,
                  onSelected: (selected) {
                    setState(() {
                      selectedIsPaid = selected ? false : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Paid'),
                  selected: selectedIsPaid == true,
                  onSelected: (selected) {
                    setState(() {
                      selectedIsPaid = selected ? true : null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedLevel = null;
                        selectedCategory = null;
                        selectedIsPaid = null;
                      });
                      _loadCourses();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _loadCourses();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCourses,
              child: courses.isEmpty
                  ? const Center(child: Text('No courses found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return _buildCourseCard(course);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          '/submit-opportunity',
          arguments: {'type': 'course'},
        ),
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Submit Course'),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showCourseDetails(course),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Platform Badge
              if (course.platform != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPlatformColor(course.platform!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    course.platform!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // Title
              Text(
                course.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (course.instructor != null) ...[
                const SizedBox(height: 4),
                Text(
                  'by ${course.instructor}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],

              const SizedBox(height: 12),

              // Metrics Row
              Row(
                children: [
                  if (course.rating > 0) ...[
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      ' ${course.rating.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                  Text(
                    ' ${course.viewsCount}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  Text(
                    ' ${course.enrolledCount} enrolled',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tags
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (course.level != null) ...[
                      Chip(
                        label: Text(
                          course.level!,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                        avatar: const Icon(Icons.bar_chart, size: 16),
                        backgroundColor: Colors.grey[200],
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (course.duration != null) ...[
                      Chip(
                        label: Text(
                          course.duration!,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                        avatar: const Icon(Icons.schedule, size: 16),
                        backgroundColor: Colors.grey[200],
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Chip(
                      label: Text(
                        course.isPaid ? 'Paid' : 'Free',
                        style: TextStyle(
                          color: course.isPaid
                              ? Colors.orange[700]
                              : Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: course.isPaid
                          ? Colors.orange[100]
                          : Colors.green[100],
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startLearning(course),
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Start Learning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'udemy':
        return Colors.purple;
      case 'scaler':
        return Colors.orange;
      case 'freecodecamp':
        return Colors.green;
      case 'coursera':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showCourseDetails(CourseModel course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              if (course.platform != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Platform: ${course.platform}',
                  style: TextStyle(
                    color: _getPlatformColor(course.platform!),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Divider(),

              // Description
              if (course.description != null) ...[
                const Text(
                  'About this course',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description!,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
              ],

              // What You'll Learn
              if (course.whatYouWillLearn != null) ...[
                const Text(
                  'What you\'ll learn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ...(_parseWhatYouWillLearn(course.whatYouWillLearn!).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 16),
              ],

              // Course Info
              const Text(
                'Course Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Duration', course.duration ?? 'N/A'),
              _buildDetailRow('Level', course.level ?? 'N/A'),
              _buildDetailRow('Category', course.category ?? 'N/A'),
              _buildDetailRow('Students Enrolled', '${course.enrolledCount}'),
              _buildDetailRow('Course Views', '${course.viewsCount}'),
              _buildDetailRow(
                'Price',
                course.isPaid ? '₹${course.price}' : 'Free',
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _startLearning(course);
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Course'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _parseWhatYouWillLearn(String jsonString) {
    try {
      final List<dynamic> items = jsonDecode(jsonString);
      return items.map((item) => item.toString()).toList();
    } catch (e) {
      // If not JSON, try splitting by newlines or commas
      return jsonString
          .split(RegExp(r'[\n,]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
  }

  Future<void> _startLearning(CourseModel course) async {
    // Track enrollment
    final result = await _apiService.enrollCourse(course.id!);

    if (result['success'] && result['course_link'] != null) {
      final url = Uri.parse(result['course_link']);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open course link')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error enrolling in course'),
          ),
        );
      }
    }
  }
}
