import 'package:flutter/material.dart';

class ChipConfig {
  final int id;
  final String chipKey;
  final String label;
  final String iconName;
  final String color;
  final int displayOrder;
  final bool isEnabled;

  ChipConfig({
    required this.id,
    required this.chipKey,
    required this.label,
    required this.iconName,
    required this.color,
    required this.displayOrder,
    required this.isEnabled,
  });

  factory ChipConfig.fromJson(Map<String, dynamic> json) {
    return ChipConfig(
      id: json['id'],
      chipKey: json['chip_key'],
      label: json['label'],
      iconName: json['icon_name'],
      color: json['color'],
      displayOrder: json['display_order'],
      isEnabled: json['is_enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chip_key': chipKey,
      'label': label,
      'icon_name': iconName,
      'color': color,
      'display_order': displayOrder,
      'is_enabled': isEnabled,
    };
  }

  /// Convert icon name string to IconData
  IconData get icon {
    final iconMap = {
      'work_outline': Icons.work_outline,
      'schedule': Icons.schedule,
      'type_specimen': Icons.category,
      'payments': Icons.payments,
      'bar_chart': Icons.bar_chart,
      'category': Icons.category,
      'info_outline': Icons.info_outline,
      'lightbulb_outline': Icons.lightbulb_outline,
      'check_circle_outline': Icons.check_circle_outline,
      'description': Icons.description,
      'assignment': Icons.assignment,
      'analytics': Icons.analytics,
      'business': Icons.business,
    };
    return iconMap[iconName] ?? Icons.info_outline;
  }

  /// Convert hex color string to Color
  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}
