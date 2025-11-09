import 'package:flutter/material.dart';
import 'package:hackifm/widgets/app_widgets.dart';

class SubmitOpportunityScreen extends StatefulWidget {
  const SubmitOpportunityScreen({super.key});

  @override
  State<SubmitOpportunityScreen> createState() =>
      _SubmitOpportunityScreenState();
}

class _SubmitOpportunityScreenState extends State<SubmitOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    'Internships',
    'Hackathons',
    'Courses',
    'Events',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Submit Opportunity',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF05060A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeonTextField(controller: _titleController, hint: 'Title'),
              const SizedBox(height: 16),
              NeonTextField(
                controller: _descriptionController,
                hint: 'Description',
              ),
              const SizedBox(height: 16),
              NeonTextField(controller: _linkController, hint: 'Link'),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),
              NeonButton(
                label: 'Submit',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Placeholder for API call
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opportunity submitted! (Placeholder)'),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
        hint: Text(
          'Select Category',
          style: TextStyle(color: Colors.white.withOpacity(0.45)),
        ),
        dropdownColor: const Color(0xFF05060A),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(border: InputBorder.none),
        items: _categories.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCategory = newValue;
          });
        },
        validator: (value) => value == null ? 'Please select a category' : null,
      ),
    );
  }
}
