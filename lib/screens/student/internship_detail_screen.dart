import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/comprehensive_models.dart';
import '../../models/section_config.dart';
import '../../models/chip_config.dart';
import '../../services/api_service.dart';
import 'package:share_plus/share_plus.dart';

class InternshipDetailScreen extends StatefulWidget {
  final Internship internship;

  const InternshipDetailScreen({Key? key, required this.internship})
    : super(key: key);

  @override
  State<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends State<InternshipDetailScreen> {
  final ApiService _apiService = ApiService();
  bool isSaved = false;
  bool hasApplied = false;

  // Dynamic configurations
  List<SectionConfig> _sections = [];
  List<ChipConfig> _chips = [];
  bool _configLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigurations();
    _incrementViewCount();
  }

  Future<void> _loadConfigurations() async {
    try {
      final sectionsData = await _apiService.getSectionConfigurations();
      final chipsData = await _apiService.getChipConfigurations();

      setState(() {
        _sections = sectionsData
            .map((json) => SectionConfig.fromJson(json))
            .toList();
        _chips = chipsData.map((json) => ChipConfig.fromJson(json)).toList();
        _configLoading = false;
      });
    } catch (e) {
      print('Error loading configurations: $e');
      setState(() => _configLoading = false);
    }
  }

  Future<void> _incrementViewCount() async {
    // Track view - increments views_count on backend
    await _apiService.getInternshipById(widget.internship.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        title: const Text('Internship Details'),
        actions: [
          IconButton(
            icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleSave,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareInternship,
          ),
        ],
      ),
      body: _configLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  ..._buildDynamicSections(),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Color(0xFF3498DB)),
      child: Row(
        children: [
          // Company Logo
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.internship.companyLogo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.internship.companyLogo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          widget.internship.company[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      widget.internship.company[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.internship.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.internship.company,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                if (widget.internship.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.internship.location!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicSections() {
    final widgets = <Widget>[];

    for (final section in _sections) {
      // Build the appropriate section based on section_key
      Widget? sectionWidget;

      switch (section.sectionKey) {
        case 'basic_info':
          sectionWidget = _buildBasicInfoDynamic(section);
          break;
        case 'skills':
          sectionWidget = _buildSkillsSectionDynamic(section);
          break;
        case 'eligibility':
          sectionWidget = _buildEligibilitySectionDynamic(section);
          break;
        case 'description':
          sectionWidget = _buildDescriptionSectionDynamic(section);
          break;
        case 'application':
          sectionWidget = _buildApplicationSectionDynamic(section);
          break;
        case 'analytics':
          sectionWidget = _buildAnalyticsDynamic(section);
          break;
        case 'company':
          sectionWidget = _buildCompanyInfoDynamic(section);
          break;
      }

      if (sectionWidget != null) {
        widgets.add(sectionWidget);
        widgets.add(const Divider(height: 32));
      }
    }

    return widgets;
  }

  Widget _buildBasicInfoDynamic(SectionConfig config) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: config.colorValue, size: 24),
              const SizedBox(width: 8),
              Text(
                config.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: config.colorValue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _chips.map((chip) {
              String? value;
              switch (chip.chipKey) {
                case 'work_type':
                  value = widget.internship.workType;
                  break;
                case 'duration':
                  value = widget.internship.duration;
                  break;
                case 'internship_type':
                  value = widget.internship.internshipType;
                  break;
                case 'stipend':
                  value = widget.internship.isPaid
                      ? '₹${widget.internship.stipendMin}-${widget.internship.stipendMax}/month'
                      : 'Unpaid';
                  break;
                case 'experience_level':
                  value = widget.internship.experienceLevel;
                  break;
                case 'category':
                  value = widget.internship.category;
                  break;
              }

              if (value == null || value.isEmpty)
                return const SizedBox.shrink();

              return _buildInfoChipDynamic(chip, value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChipDynamic(ChipConfig chip, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: chip.colorValue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chip.colorValue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chip.icon, size: 18, color: chip.colorValue),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chip.label,
                style: TextStyle(
                  fontSize: 10,
                  color: chip.colorValue.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: chip.colorValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSectionDynamic(SectionConfig config) {
    if (widget.internship.skillsRequired == null ||
        widget.internship.skillsRequired!.isEmpty) {
      return const SizedBox.shrink();
    }

    final skills = widget.internship.skillsRequired!.split(',');

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: config.colorValue, size: 24),
              const SizedBox(width: 8),
              Text(
                config.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: config.colorValue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) {
              return Chip(
                label: Text(skill.trim()),
                backgroundColor: config.colorValue.withOpacity(0.1),
                labelStyle: TextStyle(color: config.colorValue),
                side: BorderSide(color: config.colorValue.withOpacity(0.3)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilitySectionDynamic(SectionConfig config) {
    if (widget.internship.eligibility == null ||
        widget.internship.eligibility!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: config.colorValue, size: 24),
              const SizedBox(width: 8),
              Text(
                config.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: config.colorValue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: config.colorValue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: config.colorValue.withOpacity(0.3)),
            ),
            child: Text(
              widget.internship.eligibility!,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSectionDynamic(SectionConfig config) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: config.colorValue, size: 24),
              const SizedBox(width: 8),
              Text(
                config.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: config.colorValue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.internship.description != null &&
              widget.internship.description!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.internship.description!,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
              ),
            ),
          if (widget.internship.responsibilities != null &&
              widget.internship.responsibilities!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Responsibilities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: config.colorValue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.internship.responsibilities!,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[800],
              ),
            ),
          ],
          if (widget.internship.whatYouWillLearn != null &&
              widget.internship.whatYouWillLearn!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'What You Will Learn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: config.colorValue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.internship.whatYouWillLearn!,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[800],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApplicationSectionDynamic(SectionConfig config) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: config.colorValue, size: 24),
              const SizedBox(width: 8),
              Text(
                config.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: config.colorValue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.internship.applicationDeadline != null)
            _buildDetailRowDynamic(
              'Application Deadline',
              widget.internship.applicationDeadline!,
              config.colorValue,
            ),
          const SizedBox(height: 12),
          _buildDetailRowDynamic(
            'Application Method',
            widget.internship.applyThroughPlatform == true
                ? 'Apply through HackIFM'
                : 'External Application',
            config.colorValue,
          ),
          if (widget.internship.applyLink != null &&
              widget.internship.applyLink!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _launchURL(widget.internship.applyLink!),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Visit Application Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: config.colorValue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsDynamic(SectionConfig config) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: config.colorValue, size: 24),
              const SizedBox(width: 8),
              Text(
                config.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: config.colorValue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCardDynamic(
                'Views',
                widget.internship.viewsCount?.toString() ?? '0',
                Icons.visibility,
                config.colorValue,
              ),
              _buildStatCardDynamic(
                'Clicks',
                widget.internship.clicksCount?.toString() ?? '0',
                Icons.touch_app,
                config.colorValue,
              ),
              _buildStatCardDynamic(
                'Applied',
                widget.internship.appliedCount?.toString() ?? '0',
                Icons.how_to_reg,
                config.colorValue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoDynamic(SectionConfig config) {
    if (widget.internship.companyDescription == null ||
        widget.internship.companyDescription!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: config.colorValue, size: 24),
              const SizedBox(width: 8),
              Text(
                config.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: config.colorValue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: config.colorValue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: config.colorValue.withOpacity(0.3)),
            ),
            child: Text(
              widget.internship.companyDescription!,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowDynamic(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardDynamic(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildInfoChip(
                Icons.work_outline,
                'Mode',
                widget.internship.workType ?? 'Not specified',
                Colors.blue,
              ),
              _buildInfoChip(
                Icons.schedule,
                'Duration',
                widget.internship.duration ?? 'Flexible',
                Colors.green,
              ),
              if (widget.internship.internshipType != null)
                _buildInfoChip(
                  Icons.type_specimen,
                  'Type',
                  widget.internship.internshipType!,
                  Colors.purple,
                ),
              _buildInfoChip(
                Icons.payments,
                'Stipend',
                _getStipendText(),
                widget.internship.isPaid ? Colors.green : Colors.grey,
              ),
              if (widget.internship.experienceLevel != null)
                _buildInfoChip(
                  Icons.bar_chart,
                  'Level',
                  widget.internship.experienceLevel!,
                  Colors.orange,
                ),
              if (widget.internship.category != null)
                _buildInfoChip(
                  Icons.category,
                  'Category',
                  widget.internship.category!,
                  Colors.teal,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStipendText() {
    if (!widget.internship.isPaid) {
      return widget.internship.stipendType ?? 'Unpaid';
    }
    if (widget.internship.stipendMin != null &&
        widget.internship.stipendMax != null) {
      return '₹${widget.internship.stipendMin}-${widget.internship.stipendMax}/mo';
    }
    if (widget.internship.stipendType != null) {
      return widget.internship.stipendType!;
    }
    return 'Paid';
  }

  Widget _buildSkillsSection() {
    final skills = widget.internship.getSkillsList();
    final tools = widget.internship.getToolsList();

    if (skills.isEmpty && tools.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Skills Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (skills.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: const TextStyle(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (tools.isNotEmpty) ...[
            const Text(
              'Tools & Technologies',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tools
                  .map(
                    (tool) => Chip(
                      label: Text(tool),
                      backgroundColor: Colors.green.shade50,
                      labelStyle: const TextStyle(color: Colors.green),
                      avatar: const Icon(
                        Icons.build,
                        size: 16,
                        color: Colors.green,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEligibilitySection() {
    final eligibility = widget.internship.getEligibilityMap();
    if (widget.internship.eligibility == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Eligibility',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEligibilityItem(
            eligibility['students_only'],
            'Open to students only',
          ),
          _buildEligibilityItem(
            eligibility['graduates_allowed'],
            'Graduates can apply',
          ),
          if (eligibility['degree_required'] != null)
            _buildEligibilityItem(
              true,
              'Degree required: ${eligibility['degree_required']}',
            ),
          if (eligibility['branch_specific'] != null)
            _buildEligibilityItem(
              true,
              'Branch: ${eligibility['branch_specific']}',
            ),
        ],
      ),
    );
  }

  Widget _buildEligibilityItem(bool? condition, String text) {
    if (condition == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            condition ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: condition ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Job Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.internship.description != null) ...[
            Text(
              widget.internship.description!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.internship.responsibilities != null) ...[
            const Text(
              'Responsibilities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.internship.responsibilities!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.internship.whatYouWillLearn != null) ...[
            const Text(
              'What You Will Learn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.internship.whatYouWillLearn!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApplicationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Application Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.internship.applicationDeadline != null) ...[
            _buildDetailRow(
              Icons.calendar_today,
              'Application Deadline',
              _formatDate(widget.internship.applicationDeadline!),
              Colors.red,
            ),
            const SizedBox(height: 8),
          ],
          _buildDetailRow(
            Icons.link,
            'Apply Via',
            widget.internship.applyThroughPlatform
                ? 'HackIFM Platform'
                : 'External Link',
            Colors.blue,
          ),
          if (widget.internship.applyLink != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _launchURL(widget.internship.applyLink!),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Visit Application Page'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalytics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnalyticCard(
                Icons.visibility,
                'Views',
                widget.internship.viewsCount,
              ),
              _buildAnalyticCard(
                Icons.touch_app,
                'Clicks',
                widget.internship.clicksCount,
              ),
              _buildAnalyticCard(
                Icons.people,
                'Applied',
                widget.internship.appliedCount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(IconData icon, String label, int count) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    if (widget.internship.companyDescription == null)
      return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.business, color: Colors.indigo),
              SizedBox(width: 8),
              Text(
                'About Company',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.internship.companyDescription!,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _toggleSave,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF3498DB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                  const SizedBox(width: 8),
                  Text(isSaved ? 'Saved' : 'Save'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: hasApplied ? null : _applyNow,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
              ),
              child: Text(hasApplied ? 'Applied' : 'Apply Now'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSave() async {
    final result = await _apiService.addSavedItem(
      opportunityType: 'internship',
      opportunityId: widget.internship.id!,
      opportunityTitle: widget.internship.title,
      opportunityCompany: widget.internship.company,
    );

    if (mounted) {
      setState(() => isSaved = !isSaved);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Saved')));
    }
  }

  Future<void> _applyNow() async {
    if (widget.internship.applyThroughPlatform) {
      final result = await _apiService.applyToInternship(widget.internship.id!);

      if (mounted) {
        setState(() => hasApplied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Application submitted'),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    } else if (widget.internship.applyLink != null) {
      _launchURL(widget.internship.applyLink!);
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  void _shareInternship() {
    Share.share(
      'Check out this internship: ${widget.internship.title} at ${widget.internship.company}',
      subject: widget.internship.title,
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }
}
