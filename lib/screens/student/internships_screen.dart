import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/comprehensive_models.dart';
import 'internship_detail_screen.dart';

class InternshipsScreen extends StatefulWidget {
  const InternshipsScreen({Key? key}) : super(key: key);

  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen> {
  final ApiService _apiService = ApiService();
  List<Internship> internships = [];
  bool isLoading = true;

  // Filters
  String? selectedWorkType;
  bool? selectedIsPaid;
  String? selectedDuration;
  int? minStipend;
  int? maxStipend;
  String? selectedDatePosted;

  final List<String> workTypes = ['Remote', 'Hybrid', 'Onsite'];
  final List<String> durations = [
    '1 month',
    '2 months',
    '3 months',
    '6 months',
    '1 year',
  ];
  final List<String> datePostedOptions = ['24h', '7d', '30d'];

  @override
  void initState() {
    super.initState();
    _loadInternships();
  }

  Future<void> _loadInternships() async {
    setState(() => isLoading = true);

    final result = await _apiService.getInternships(
      workType: selectedWorkType,
      isPaid: selectedIsPaid,
      duration: selectedDuration,
      stipendMin: minStipend,
      stipendMax: maxStipend,
      datePosted: selectedDatePosted,
    );

    if (result['success']) {
      setState(() {
        internships = (result['internships'] as List)
            .map((i) => Internship.fromJson(i))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error loading internships'),
          ),
        );
      }
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: ListView(
              controller: scrollController,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498DB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Color(0xFF3498DB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Filter Internships',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Work Type Section
                _buildFilterSection(
                  'Work Type',
                  Icons.business_center_outlined,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: workTypes
                        .map(
                          (type) => FilterChip(
                            label: Text(type),
                            selected: selectedWorkType == type,
                            selectedColor: const Color(
                              0xFF3498DB,
                            ).withOpacity(0.2),
                            checkmarkColor: const Color(0xFF3498DB),
                            backgroundColor: Colors.grey[100],
                            onSelected: (selected) {
                              setState(() {
                                selectedWorkType = selected ? type : null;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Stipend Section
                _buildFilterSection(
                  'Stipend Type',
                  Icons.payments_outlined,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Paid'),
                        selected: selectedIsPaid == true,
                        selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
                        backgroundColor: Colors.grey[100],
                        onSelected: (selected) {
                          setState(() {
                            selectedIsPaid = selected ? true : null;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Unpaid'),
                        selected: selectedIsPaid == false,
                        selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
                        backgroundColor: Colors.grey[100],
                        onSelected: (selected) {
                          setState(() {
                            selectedIsPaid = selected ? false : null;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('All'),
                        selected: selectedIsPaid == null,
                        selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
                        backgroundColor: Colors.grey[100],
                        onSelected: (selected) {
                          setState(() {
                            selectedIsPaid = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stipend Range
                if (selectedIsPaid == true) ...[
                  _buildFilterSection(
                    'Stipend Range (₹/month)',
                    Icons.currency_rupee,
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Min',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                minStipend = int.tryParse(value);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('—', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Max',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                maxStipend = int.tryParse(value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Duration Section
                _buildFilterSection(
                  'Duration',
                  Icons.schedule_outlined,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: durations
                        .map(
                          (dur) => FilterChip(
                            label: Text(dur),
                            selected: selectedDuration == dur,
                            selectedColor: const Color(
                              0xFF3498DB,
                            ).withOpacity(0.2),
                            checkmarkColor: const Color(0xFF3498DB),
                            backgroundColor: Colors.grey[100],
                            onSelected: (selected) {
                              setState(() {
                                selectedDuration = selected ? dur : null;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Date Posted Section
                _buildFilterSection(
                  'Date Posted',
                  Icons.date_range_outlined,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Last 24 hours'),
                        selected: selectedDatePosted == '24h',
                        selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF3498DB),
                        backgroundColor: Colors.grey[100],
                        onSelected: (selected) {
                          setState(() {
                            selectedDatePosted = selected ? '24h' : null;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Last 7 days'),
                        selected: selectedDatePosted == '7d',
                        selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF3498DB),
                        backgroundColor: Colors.grey[100],
                        onSelected: (selected) {
                          setState(() {
                            selectedDatePosted = selected ? '7d' : null;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Last 30 days'),
                        selected: selectedDatePosted == '30d',
                        selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF3498DB),
                        backgroundColor: Colors.grey[100],
                        onSelected: (selected) {
                          setState(() {
                            selectedDatePosted = selected ? '30d' : null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            selectedWorkType = null;
                            selectedIsPaid = null;
                            selectedDuration = null;
                            minStipend = null;
                            maxStipend = null;
                            selectedDatePosted = null;
                          });
                          _loadInternships();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          _loadInternships();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF3498DB)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
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
        title: const Text('Internships'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar - Filter Panel
          Container(
            width: 280,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedWorkType = null;
                            selectedIsPaid = null;
                            selectedDuration = null;
                            minStipend = null;
                            maxStipend = null;
                            selectedDatePosted = null;
                          });
                          _loadInternships();
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Status Filter
                  _buildSidebarSection(
                    'Status',
                    Column(
                      children: [
                        _buildCheckboxTile('Live', selectedDatePosted == null),
                        _buildCheckboxTile(
                          'Recent',
                          selectedDatePosted == '7d',
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Type Filter (Work Type)
                  _buildSidebarSection(
                    'Type',
                    Column(
                      children: workTypes.map((type) {
                        return _buildCheckboxTile(
                          type,
                          selectedWorkType == type,
                          onChanged: (val) {
                            setState(() {
                              selectedWorkType = val! ? type : null;
                            });
                            _loadInternships();
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  const Divider(),

                  // Stipend Filter
                  _buildSidebarSection(
                    'Stipend',
                    Column(
                      children: [
                        _buildCheckboxTile(
                          'Paid',
                          selectedIsPaid == true,
                          onChanged: (val) {
                            setState(() {
                              selectedIsPaid = val! ? true : null;
                            });
                            _loadInternships();
                          },
                        ),
                        _buildCheckboxTile(
                          'Unpaid',
                          selectedIsPaid == false,
                          onChanged: (val) {
                            setState(() {
                              selectedIsPaid = val! ? false : null;
                            });
                            _loadInternships();
                          },
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Duration Filter
                  _buildSidebarSection(
                    'Duration',
                    Column(
                      children: durations.map((dur) {
                        return _buildCheckboxTile(
                          dur,
                          selectedDuration == dur,
                          onChanged: (val) {
                            setState(() {
                              selectedDuration = val! ? dur : null;
                            });
                            _loadInternships();
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  const Divider(),

                  // Date Posted Filter
                  _buildSidebarSection(
                    'Timing',
                    Column(
                      children: [
                        _buildCheckboxTile(
                          'Last 24 hours',
                          selectedDatePosted == '24h',
                          onChanged: (val) {
                            setState(() {
                              selectedDatePosted = val! ? '24h' : null;
                            });
                            _loadInternships();
                          },
                        ),
                        _buildCheckboxTile(
                          'Last 7 days',
                          selectedDatePosted == '7d',
                          onChanged: (val) {
                            setState(() {
                              selectedDatePosted = val! ? '7d' : null;
                            });
                            _loadInternships();
                          },
                        ),
                        _buildCheckboxTile(
                          'Last 30 days',
                          selectedDatePosted == '30d',
                          onChanged: (val) {
                            setState(() {
                              selectedDatePosted = val! ? '30d' : null;
                            });
                            _loadInternships();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side - Content Area
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadInternships,
                    child: internships.isEmpty
                        ? const Center(child: Text('No internships found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: internships.length,
                            itemBuilder: (context, index) {
                              final internship = internships[index];
                              return _buildInternshipCard(internship);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          '/submit-opportunity',
          arguments: {'type': 'internship'},
        ),
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Submit Internship'),
      ),
    );
  }

  Widget _buildSidebarSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCheckboxTile(
    String label,
    bool value, {
    Function(bool?)? onChanged,
  }) {
    return CheckboxListTile(
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF3498DB),
      onChanged: onChanged ?? (val) {},
    );
  }

  Widget _buildInternshipCard(Internship internship) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _viewDetails(internship),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Company Logo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498DB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: internship.companyLogo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              internship.companyLogo!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Text(
                                      internship.company[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3498DB),
                                      ),
                                    ),
                                  ),
                            ),
                          )
                        : Center(
                            child: Text(
                              internship.company[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3498DB),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                internship.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Experience Level Badge
                            if (internship.experienceLevel != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getExperienceLevelColor(
                                    internship.experienceLevel!,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  internship.experienceLevel!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          internship.company,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  _buildBookmarkButton(internship),
                ],
              ),

              if (internship.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      internship.location!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              Text(
                internship.description ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Application Deadline Badge
              if (internship.applicationDeadline != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Apply by ${_formatDeadline(internship.applicationDeadline!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (internship.workType != null)
                    Chip(
                      label: Text(
                        internship.workType!,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      avatar: Icon(
                        _getWorkTypeIcon(internship.workType!),
                        size: 16,
                      ),
                      backgroundColor: Colors.grey[200],
                      visualDensity: VisualDensity.compact,
                    ),
                  if (internship.internshipType != null)
                    Chip(
                      label: Text(
                        internship.internshipType!,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      backgroundColor: Colors.grey[200],
                      visualDensity: VisualDensity.compact,
                    ),
                  if (internship.duration != null)
                    Chip(
                      label: Text(
                        internship.duration!,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      avatar: const Icon(Icons.schedule, size: 16),
                      backgroundColor: Colors.grey[200],
                      visualDensity: VisualDensity.compact,
                    ),
                  if (internship.isPaid && internship.stipendMax != null)
                    Chip(
                      label: Text(
                        '₹${internship.stipendMin}-${internship.stipendMax}/mo',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Colors.green[100],
                      avatar: Icon(
                        Icons.payments,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      visualDensity: VisualDensity.compact,
                    )
                  else if (internship.stipendType != null)
                    Chip(
                      label: Text(
                        internship.stipendType!,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      backgroundColor: Colors.grey[200],
                      avatar: const Icon(Icons.money_off, size: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.grey,
                      ),
                      Text(
                        ' ${internship.viewsCount}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      Text(
                        ' ${internship.appliedCount} applied',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _applyInternship(internship),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Apply Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getExperienceLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getWorkTypeIcon(String workType) {
    switch (workType.toLowerCase()) {
      case 'remote':
        return Icons.home_outlined;
      case 'hybrid':
        return Icons.business_center;
      case 'onsite':
      case 'on-site':
        return Icons.location_city;
      default:
        return Icons.work_outline;
    }
  }

  String _formatDeadline(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = date.difference(now);

      if (difference.inDays > 0) {
        return '${difference.inDays} days';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours';
      } else {
        return 'Today';
      }
    } catch (e) {
      return isoDate;
    }
  }

  Widget _buildBookmarkButton(Internship internship) {
    return IconButton(
      icon: const Icon(Icons.bookmark_border),
      onPressed: () => _saveInternship(internship),
    );
  }

  void _viewDetails(Internship internship) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InternshipDetailScreen(internship: internship),
      ),
    ).then((_) => _loadInternships()); // Reload after viewing
  }

  Future<void> _applyInternship(Internship internship) async {
    final result = await _apiService.applyToInternship(internship.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Application submitted')),
      );

      if (result['success']) {
        _loadInternships(); // Reload to update applied count
      }
    }
  }

  Future<void> _saveInternship(Internship internship) async {
    final result = await _apiService.addSavedItem(
      opportunityType: 'internship',
      opportunityId: internship.id!,
      opportunityTitle: internship.title,
      opportunityCompany: internship.company,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Saved successfully')),
      );
    }
  }
}
