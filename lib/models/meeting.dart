import 'package:flutter/material.dart';

class Meeting {
  Meeting({
    required this.eventName,
    required this.from,
    required this.to,
    this.background = const Color(0xFF76DDEC),
    this.isAllDay = false,
    this.threadId = 0,
    this.folderId = 0,
    this.notes = '',
    this.isCompleted = false,
  });

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  int threadId;
  int folderId;
  String notes;
  bool isCompleted;
}
