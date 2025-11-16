import 'package:flutter/material.dart';
import 'package:hackifm/database/database_helper.dart';

class AdminAddHackathonScreen extends StatefulWidget {
  const AdminAddHackathonScreen({super.key});

  @override
  State<AdminAddHackathonScreen> createState() =>
      _AdminAddHackathonScreenState();
}

class _AdminAddHackathonScreenState extends State<AdminAddHackathonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _organizerController = TextEditingController();
  final _dateController = TextEditingController();
  final _prizeController = TextEditingController();
  final _linkController = TextEditingController();
  final _participantsController = TextEditingController();

  String _selectedStatus = 'Upcoming';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _dateController.dispose();
    _prizeController.dispose();
    _linkController.dispose();
    _participantsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFE74C3C)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _saveHackathon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = DatabaseHelper();
      await db.insertHackathon({
        'title': _titleController.text.trim(),
        'organizer': _organizerController.text.trim(),
        'date': _dateController.text.trim(),
        'prize': _prizeController.text.trim(),
        'participants': _participantsController.text.trim(),
        'status': _selectedStatus,
        'registered': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Hackathon added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Add Hackathon'),
        backgroundColor: const Color(0xFFE74C3C),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Color(0xFFE74C3C),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fill in the hackathon details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                _buildTextField(
                  controller: _titleController,
                  label: 'Title *',
                  hint: 'e.g., Smart India Hackathon 2025',
                  icon: Icons.title,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter hackathon title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Organizer
                _buildTextField(
                  controller: _organizerController,
                  label: 'Organizer *',
                  hint: 'e.g., Government of India',
                  icon: Icons.business,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter organizer name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Date
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _dateController,
                      label: 'Date *',
                      hint: 'Select date',
                      icon: Icons.calendar_today,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Prize
                _buildTextField(
                  controller: _prizeController,
                  label: 'Prize (₹) *',
                  hint: 'e.g., ₹1,00,000',
                  icon: Icons.currency_rupee,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter prize amount';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Registration Link
                _buildTextField(
                  controller: _linkController,
                  label: 'Registration Link *',
                  hint: 'https://...',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter registration link';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Participants (Optional)
                _buildTextField(
                  controller: _participantsController,
                  label: 'Expected Participants (Optional)',
                  hint: 'e.g., 10,000+',
                  icon: Icons.people,
                ),

                const SizedBox(height: 16),

                // Status Dropdown
                const Text(
                  'Status *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      items: ['Upcoming', 'Live', 'Ended'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Icon(
                                value == 'Upcoming'
                                    ? Icons.schedule
                                    : value == 'Live'
                                    ? Icons.play_circle
                                    : Icons.check_circle,
                                color: value == 'Upcoming'
                                    ? Colors.orange
                                    : value == 'Live'
                                    ? Colors.green
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(value),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedStatus = newValue);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveHackathon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Hackathon',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFFE74C3C)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
