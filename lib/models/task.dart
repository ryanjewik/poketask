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
    this.recurrence,
    this.recurrenceId,
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
  String? folderId; // Changed to String? to allow null values
  bool isCompleted;
  String? color; // Hex color string from folder, nullable
  String? recurrence; // 'daily' | 'weekly' | 'monthly', null when not recurring
  String? recurrenceId; // Shared by every occurrence in a recurring series

  bool get isRecurring => recurrenceId != null && recurrenceId!.isNotEmpty;

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
      folderId: json['folder_id'] == null ? null : json['folder_id'].toString(),
      isCompleted: json['is_completed'] ?? false,
      recurrence: json['recurrence'] as String?,
      recurrenceId: json['recurrence_id']?.toString(),
    );
  }

  // Row for task_table inserts. Recurrence keys are only sent for recurring
  // tasks so plain inserts keep working against a schema without those columns.
  Map<String, dynamic> toInsertJson() {
    return {
      'task_id': taskId,
      'created_at': createdAt.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'date_completed': dateCompleted.toIso8601String(),
      'is_all_day': isAllDay,
      'high_priority': highPriority,
      'task_notes': taskNotes,
      'task_text': taskText,
      'trainer_id': trainerId,
      'thread_id': threadId.isEmpty ? null : threadId,
      'folder_id': (folderId == null || folderId!.isEmpty) ? null : folderId,
      'is_completed': isCompleted,
      if (isRecurring) 'recurrence': recurrence,
      if (isRecurring) 'recurrence_id': recurrenceId,
    };
  }

  // Add computed properties for UI compatibility
  String get eventName => taskText;
  String get notes => taskNotes;
  Color get background => _colorFromHex(color) ?? (highPriority ? Colors.redAccent : (isAllDay ? Colors.amberAccent : Colors.redAccent.withOpacity(0.7)));
  bool get completed => isCompleted;
  DateTime get to => endDate;
}

// All-day tasks span from the very start to the very end of their day(s).
DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59);

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
