/*
import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  bool isNew;
  final String type;
  final Map<String, dynamic> payload;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.isNew,
    required this.type,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'icon': icon.codePoint,
      'color': color.value,
      'isNew': isNew,
      'type': type,
      'payload': payload,
    };
  }

  static NotificationItem fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      time: json['time'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      isNew: json['isNew'],
      type: json['type'],
      payload: Map<String, dynamic>.from(json['payload']),
    );
  }
}*/
import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  bool isNew;
  final String type;
  final Map<String, dynamic> payload;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.isNew,
    required this.type,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'icon': _iconToString(icon),  // store name instead of codePoint
      'color': color.value,
      'isNew': isNew,
      'type': type,
      'payload': payload,
    };
  }

  static NotificationItem fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      time: json['time'],
      icon: _stringToIcon(json['icon']), // restore from name
      color: Color(json['color']),
      isNew: json['isNew'],
      type: json['type'],
      payload: Map<String, dynamic>.from(json['payload']),
    );
  }

  // 🔑 Helper: Convert IconData to String
  static String _iconToString(IconData icon) {
    if (icon == Icons.notifications) return 'notifications';
    if (icon == Icons.email) return 'email';
    if (icon == Icons.message) return 'message';
    return 'notifications'; // default fallback
  }

  // 🔑 Helper: Convert String back to IconData
  static IconData _stringToIcon(String iconName) {
    switch (iconName) {
      case 'email':
        return Icons.email;
      case 'message':
        return Icons.message;
      case 'notifications':
      default:
        return Icons.notifications;
    }
  }
}
