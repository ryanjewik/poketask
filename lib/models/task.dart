import 'package:flutter/material.dart';

class Task {
  Task({
    required this.taskId,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.dateCompleted,
    required this.isAllDay,
    required this.highPriority,
    required this.taskNotes,
    required this.taskText,
    required this.trainerId,
    required this.threadId,
    required this.folderId,
    required this.isCompleted,
    this.color,
  });

  String taskId;
  DateTime createdAt;
  DateTime startDate;
  DateTime endDate;
  DateTime dateCompleted;
  bool isAllDay;
  bool highPriority;
  String taskNotes;
  String taskText;
  String trainerId;
  String threadId;
  String folderId;
  bool isCompleted;
  String? color; // Hex color string from folder, nullable

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['task_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      dateCompleted: DateTime.tryParse(json['date_completed'] ?? '') ?? DateTime.now(),
      isAllDay: json['is_all_day'] ?? false,
      highPriority: json['high_priority'] ?? false,
      taskNotes: json['task_notes'] ?? '',
      taskText: json['task_text'] ?? '',
      trainerId: json['trainer_id']?.toString() ?? '',
      threadId: json['thread_id']?.toString() ?? '',
      folderId: json['folder_id']?.toString() ?? '',
      isCompleted: json['is_completed'] ?? false,
    );
  }

  // Add computed properties for UI compatibility
  String get eventName => taskText;
  String get notes => taskNotes;
  Color get background => _colorFromHex(color) ?? (highPriority ? Colors.redAccent : (isAllDay ? Colors.amberAccent : Colors.redAccent.withOpacity(0.7)));
  bool get completed => isCompleted;
  DateTime get to => endDate;
}

Color? _colorFromHex(String? hexColor) {
  if (hexColor == null || hexColor.isEmpty) return null;
  String hex = hexColor.replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex'; // add alpha if missing
  try {
    return Color(int.parse('0x$hex'));
  } catch (_) {
    return null;
  }
}
