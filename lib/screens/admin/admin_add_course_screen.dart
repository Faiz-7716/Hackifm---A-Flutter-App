import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';

class AdminAddCourseScreen extends StatefulWidget {
  final Map<String, dynamic>? existingCourse;

  const AdminAddCourseScreen({Key? key, this.existingCourse}) : super(key: key);

  @override
  State<AdminAddCourseScreen> createState() => _AdminAddCourseScreenState();
}

class _AdminAddCourseScreenState extends State<AdminAddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  final _titleController = TextEditingController();
  final _platformController = TextEditingController();
  final _instructorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseLinkController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _durationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  
  String? selectedLevel;
  bool isPaid = false;
  List<String> learningPoints = [];
  final _learningPointController = TextEditingController();
  
  bool isLoading = false;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingCourse != null) {
      isEditMode = true;
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final course = widget.existingCourse!;
    _titleController.text = course['title'] ?? '';
    _platformController.text = course['platform'] ?? '';
    _instructorController.text = course['instructor'] ?? '';
    _descriptionController.text = course['description'] ?? '';
    _courseLinkController.text = course['course_link'] ?? '';
    _thumbnailController.text = course['thumbnail'] ?? '';
    _durationController.text = course['duration'] ?? '';
    _categoryController.text = course['category'] ?? '';
    _priceController.text = course['price']?.toString() ?? '';
    selectedLevel = course['level'];
    isPaid = course['is_paid'] ?? false;
    
    if (course['what_you_will_learn'] != null) {
      try {
        final List<dynamic> points = jsonDecode(course['what_you_will_learn']);
        learningPoints = points.map((p) => p.toString()).toList();
      } catch (e) {
        // Handle as plain text
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Course' : 'Add New Course'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Course Title*',
                hintText: 'e.g., Complete Python Bootcamp',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Platform
            TextFormField(
              controller: _platformController,
              decoration: const InputDecoration(
                labelText: 'Platform*',
                hintText: 'e.g., Udemy, Scaler, FreeCodeCamp',
                border: OutlineInputBorder(),
                helperText: 'Where is this course hosted?',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter platform';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Instructor
            TextFormField(
              controller: _instructorController,
              decoration: const InputDecoration(
                labelText: 'Instructor',
                hintText: 'e.g., Dr. Angela Yu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description*',
                hintText: 'Brief overview of the course...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Course Link
            TextFormField(
              controller: _courseLinkController,
              decoration: const InputDecoration(
                labelText: 'Course URL*',
                hintText: 'https://...',
                border: OutlineInputBorder(),
                helperText: 'External link to the course',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course URL';
                }
                if (!value.startsWith('http')) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Thumbnail URL
            TextFormField(
              controller: _thumbnailController,
              decoration: const InputDecoration(
                labelText: 'Thumbnail URL',
                hintText: 'https://image-url.com/thumbnail.jpg',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // What You'll Learn Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What Students Will Learn',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...learningPoints.asMap().entries.map((entry) => ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(entry.value),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            learningPoints.removeAt(entry.key);
                          });
                        },
                      ),
                    )),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _learningPointController,
                            decoration: const InputDecoration(
                              hintText: 'Add learning point...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_learningPointController.text.isNotEmpty) {
                              setState(() {
                                learningPoints.add(_learningPointController.text);
                                _learningPointController.clear();
                              });
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Duration
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration*',
                hintText: 'e.g., 30 hours, 6 weeks',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter duration';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Level Dropdown
            DropdownButtonFormField<String>(
              value: selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Level*',
                border: OutlineInputBorder(),
              ),
              items: ['Beginner', 'Intermediate', 'Advanced']
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedLevel = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select level';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Category
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category*',
                hintText: 'e.g., Web Dev, Data Science, AI',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Price Section
            SwitchListTile(
              title: const Text('Paid Course'),
              value: isPaid,
              onChanged: (value) {
                setState(() {
                  isPaid = value;
                });
              },
            ),
            
            if (isPaid) ...[
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (₹)',
                  hintText: '999',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (isPaid && (value == null || value.isEmpty)) {
                    return 'Please enter price';
                  }
                  return null;
                },
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitCourse,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditMode ? 'Update Course' : 'Add Course'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    final courseData = {
      'title': _titleController.text,
      'platform': _platformController.text,
      'instructor': _instructorController.text.isEmpty ? null : _instructorController.text,
      'description': _descriptionController.text,
      'course_link': _courseLinkController.text,
      'thumbnail': _thumbnailController.text.isEmpty ? null : _thumbnailController.text,
      'what_you_will_learn': jsonEncode(learningPoints),
      'duration': _durationController.text,
      'level': selectedLevel,
      'category': _categoryController.text,
      'is_paid': isPaid,
      'price': isPaid ? double.tryParse(_priceController.text) : null,
    };

    final result = isEditMode
        ? await _apiService.adminUpdateCourse(widget.existingCourse!['id'], courseData)
        : await _apiService.adminAddCourse(courseData);

    setState(() => isLoading = false);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '${isEditMode ? "Updated" : "Added"} successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _platformController.dispose();
    _instructorController.dispose();
    _descriptionController.dispose();
    _courseLinkController.dispose();
    _thumbnailController.dispose();
    _durationController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _learningPointController.dispose();
    super.dispose();
  }
}
