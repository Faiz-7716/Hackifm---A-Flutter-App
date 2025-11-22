import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/comprehensive_models.dart';
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

  @override
  void initState() {
    super.initState();
    _incrementViewCount();
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildBasicInfo(),
            const Divider(height: 32),
            _buildSkillsSection(),
            const Divider(height: 32),
            _buildEligibilitySection(),
            const Divider(height: 32),
            _buildDescriptionSection(),
            const Divider(height: 32),
            _buildApplicationSection(),
            const Divider(height: 32),
            _buildAnalytics(),
            const Divider(height: 32),
            _buildCompanyInfo(),
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
