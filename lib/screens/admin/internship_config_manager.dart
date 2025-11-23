import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/section_config.dart';
import '../../models/chip_config.dart';

class InternshipConfigManager extends StatefulWidget {
  const InternshipConfigManager({Key? key}) : super(key: key);

  @override
  State<InternshipConfigManager> createState() =>
      _InternshipConfigManagerState();
}

class _InternshipConfigManagerState extends State<InternshipConfigManager>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  List<SectionConfig> _sections = [];
  List<ChipConfig> _chips = [];
  bool _isLoading = false;

  // Predefined icon options
  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'info_outline', 'icon': Icons.info_outline},
    {'name': 'lightbulb_outline', 'icon': Icons.lightbulb_outline},
    {'name': 'check_circle_outline', 'icon': Icons.check_circle_outline},
    {'name': 'description', 'icon': Icons.description},
    {'name': 'assignment', 'icon': Icons.assignment},
    {'name': 'analytics', 'icon': Icons.analytics},
    {'name': 'business', 'icon': Icons.business},
    {'name': 'work_outline', 'icon': Icons.work_outline},
    {'name': 'schedule', 'icon': Icons.schedule},
    {'name': 'category', 'icon': Icons.category},
    {'name': 'payments', 'icon': Icons.payments},
    {'name': 'bar_chart', 'icon': Icons.bar_chart},
  ];

  // Predefined color options
  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Blue', 'hex': '#2196F3', 'color': Color(0xFF2196F3)},
    {'name': 'Green', 'hex': '#4CAF50', 'color': Color(0xFF4CAF50)},
    {'name': 'Purple', 'hex': '#9C27B0', 'color': Color(0xFF9C27B0)},
    {'name': 'Orange', 'hex': '#FF9800', 'color': Color(0xFFFF9800)},
    {'name': 'Teal', 'hex': '#009688', 'color': Color(0xFF009688)},
    {'name': 'Indigo', 'hex': '#3F51B5', 'color': Color(0xFF3F51B5)},
    {'name': 'Red', 'hex': '#F44336', 'color': Color(0xFFF44336)},
    {'name': 'Grey', 'hex': '#757575', 'color': Color(0xFF757575)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadConfigurations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadConfigurations() async {
    setState(() => _isLoading = true);

    try {
      final sectionsData = await _apiService.getSectionConfigurations();
      final chipsData = await _apiService.getChipConfigurations();

      setState(() {
        _sections = sectionsData
            .map((json) => SectionConfig.fromJson(json))
            .toList();
        _chips = chipsData.map((json) => ChipConfig.fromJson(json)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading configurations: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSection(SectionConfig section) async {
    final result = await _apiService.updateSectionConfig(
      section.id,
      section.toJson(),
    );

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Section updated successfully')),
        );
        _loadConfigurations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Update failed')),
        );
      }
    }
  }

  Future<void> _updateChip(ChipConfig chip) async {
    final result = await _apiService.updateChipConfig(chip.id, chip.toJson());

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chip updated successfully')),
        );
        _loadConfigurations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Update failed')),
        );
      }
    }
  }

  void _showSectionEditDialog(SectionConfig section) {
    final titleController = TextEditingController(text: section.title);
    String selectedIcon = section.iconName;
    String selectedColor = section.color;
    bool isEnabled = section.isEnabled;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${section.sectionKey}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Section Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Icon:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _iconOptions.map((iconData) {
                    final isSelected = selectedIcon == iconData['name'];
                    return InkWell(
                      onTap: () => setDialogState(() {
                        selectedIcon = iconData['name'];
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          iconData['icon'],
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Color:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorOptions.map((colorData) {
                    final isSelected = selectedColor == colorData['hex'];
                    return InkWell(
                      onTap: () => setDialogState(() {
                        selectedColor = colorData['hex'];
                      }),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: colorData['color'],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enabled'),
                  value: isEnabled,
                  onChanged: (value) => setDialogState(() {
                    isEnabled = value;
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedSection = SectionConfig(
                  id: section.id,
                  sectionKey: section.sectionKey,
                  title: titleController.text,
                  iconName: selectedIcon,
                  color: selectedColor,
                  displayOrder: section.displayOrder,
                  isEnabled: isEnabled,
                );
                _updateSection(updatedSection);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChipEditDialog(ChipConfig chip) {
    final labelController = TextEditingController(text: chip.label);
    String selectedIcon = chip.iconName;
    String selectedColor = chip.color;
    bool isEnabled = chip.isEnabled;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${chip.chipKey}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Chip Label',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Icon:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _iconOptions.map((iconData) {
                    final isSelected = selectedIcon == iconData['name'];
                    return InkWell(
                      onTap: () => setDialogState(() {
                        selectedIcon = iconData['name'];
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          iconData['icon'],
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Color:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorOptions.map((colorData) {
                    final isSelected = selectedColor == colorData['hex'];
                    return InkWell(
                      onTap: () => setDialogState(() {
                        selectedColor = colorData['hex'];
                      }),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: colorData['color'],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enabled'),
                  value: isEnabled,
                  onChanged: (value) => setDialogState(() {
                    isEnabled = value;
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedChip = ChipConfig(
                  id: chip.id,
                  chipKey: chip.chipKey,
                  label: labelController.text,
                  iconName: selectedIcon,
                  color: selectedColor,
                  displayOrder: chip.displayOrder,
                  isEnabled: isEnabled,
                );
                _updateChip(updatedChip);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internship Configuration'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sections', icon: Icon(Icons.view_list)),
            Tab(text: 'Info Chips', icon: Icon(Icons.label)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildSectionsTab(), _buildChipsTab()],
            ),
    );
  }

  Widget _buildSectionsTab() {
    return RefreshIndicator(
      onRefresh: _loadConfigurations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          final section = _sections[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: section.colorValue,
                child: Icon(section.icon, color: Colors.white),
              ),
              title: Text(section.title),
              subtitle: Text(section.sectionKey),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: section.isEnabled,
                    onChanged: (value) {
                      final updated = SectionConfig(
                        id: section.id,
                        sectionKey: section.sectionKey,
                        title: section.title,
                        iconName: section.iconName,
                        color: section.color,
                        displayOrder: section.displayOrder,
                        isEnabled: value,
                      );
                      _updateSection(updated);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showSectionEditDialog(section),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChipsTab() {
    return RefreshIndicator(
      onRefresh: _loadConfigurations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _chips.length,
        itemBuilder: (context, index) {
          final chip = _chips[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: chip.colorValue,
                child: Icon(chip.icon, color: Colors.white),
              ),
              title: Text(chip.label),
              subtitle: Text(chip.chipKey),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: chip.isEnabled,
                    onChanged: (value) {
                      final updated = ChipConfig(
                        id: chip.id,
                        chipKey: chip.chipKey,
                        label: chip.label,
                        iconName: chip.iconName,
                        color: chip.color,
                        displayOrder: chip.displayOrder,
                        isEnabled: value,
                      );
                      _updateChip(updated);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showChipEditDialog(chip),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
