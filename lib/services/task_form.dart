import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

/// Upper bound on how many rows a single recurring series may create.
const int kMaxRecurrenceOccurrences = 366;

/// Supported recurrence values (as stored in `task_table.recurrence`) and their labels.
const Map<String, String> kRecurrenceLabels = {
  'daily': 'Daily',
  'weekly': 'Weekly',
  'monthly': 'Monthly',
};

/// Adds [months] calendar months to [d], keeping the wall-clock time and
/// clamping the day to the last day of shorter months (Jan 31 + 1 -> Feb 28/29).
DateTime addMonthsClamped(DateTime d, int months) {
  // The DateTime constructor normalizes month overflow (month 13 -> January next year).
  final target = DateTime(d.year, d.month + months);
  final lastDayOfMonth = DateTime(target.year, target.month + 1, 0).day;
  final day = d.day < lastDayOfMonth ? d.day : lastDayOfMonth;
  return DateTime(target.year, target.month, day, d.hour, d.minute, d.second, d.millisecond);
}

/// Start times of every occurrence of a series beginning at [first], repeating
/// [recurrence] ('daily' | 'weekly' | 'monthly') through the calendar day of
/// [until] (inclusive), capped at [maxCount].
///
/// Dates are built with the DateTime constructor rather than by adding
/// Durations, so the wall-clock time survives DST changes. Monthly occurrences
/// always anchor on the original day-of-month (Jan 31 -> Feb 28 -> Mar 31).
List<DateTime> recurrenceStarts(
  DateTime first,
  String recurrence,
  DateTime until, {
  int maxCount = kMaxRecurrenceOccurrences,
}) {
  final lastDay = DateTime(until.year, until.month, until.day);
  final starts = <DateTime>[];
  for (var i = 0; starts.length < maxCount; i++) {
    final DateTime next;
    switch (recurrence) {
      case 'daily':
        next = DateTime(first.year, first.month, first.day + i, first.hour,
            first.minute, first.second, first.millisecond);
      case 'weekly':
        next = DateTime(first.year, first.month, first.day + 7 * i, first.hour,
            first.minute, first.second, first.millisecond);
      case 'monthly':
        next = addMonthsClamped(first, i);
      default:
        return [first];
    }
    if (DateTime(next.year, next.month, next.day).isAfter(lastDay)) break;
    starts.add(next);
  }
  return starts;
}

/// Whole calendar days from [from]'s date to [to]'s date (DST-safe).
int calendarDaysBetween(DateTime from, DateTime to) {
  return DateTime.utc(to.year, to.month, to.day)
      .difference(DateTime.utc(from.year, from.month, from.day))
      .inDays;
}

class TaskForm extends StatefulWidget {
  final void Function(Task) onSubmit;
  final String trainerId;
  final String? threadId;
  const TaskForm({super.key, required this.onSubmit, required this.trainerId, this.threadId});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  static const Duration _defaultDuration = Duration(minutes: 30);
  static const Map<String, int> _defaultRepeatMonths = {
    'daily': 3,
    'weekly': 6,
    'monthly': 12,
  };

  final _formKey = GlobalKey<FormState>();
  String _title = '';
  late DateTime _start;
  late DateTime _end;
  // Once the user picks an end themselves, changing the start no longer moves it.
  bool _endManuallySet = false;
  bool _isAllDay = false;
  // Times in effect just before All Day was switched on, restored when it is switched off.
  DateTime? _timedStart;
  DateTime? _timedEnd;
  bool _highPriority = false;
  String _taskNotes = '';
  String? _selectedFolderId;
  List<Map<String, dynamic>> _folders = [];
  bool _isLoading = false;
  late String _threadId;

  bool _repeat = false;
  String _recurrence = 'weekly';
  // Null means "use the per-frequency default".
  DateTime? _repeatUntilOverride;

  @override
  void initState() {
    super.initState();
    _threadId = widget.threadId ?? '';
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    _end = _start.add(_defaultDuration);
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('folder_table')
          .select()
          .eq('trainer_id', widget.trainerId);
      if (!mounted) return;
      setState(() {
        _folders = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Failed to fetch folders: $e');
    }
  }

  // ---- Start / end / all-day ----

  void _applyStart(DateTime value) {
    setState(() {
      _start = _isAllDay ? startOfDay(value) : value;
      if (!_endManuallySet) {
        _end = _isAllDay ? endOfDay(_start) : _start.add(_defaultDuration);
      } else if (_isAllDay && _end.isBefore(_start)) {
        _end = endOfDay(_start);
      }
      final override = _repeatUntilOverride;
      if (override != null && override.isBefore(startOfDay(_start))) {
        _repeatUntilOverride = null;
      }
    });
  }

  void _applyEnd(DateTime value) {
    setState(() {
      _endManuallySet = true;
      _end = _isAllDay ? endOfDay(value) : value;
      if (_isAllDay && _end.isBefore(_start)) _end = endOfDay(_start);
    });
  }

  void _setAllDay(bool value) {
    if (value == _isAllDay) return;
    setState(() {
      if (value) {
        _timedStart = _start;
        _timedEnd = _end;
        _isAllDay = true;
        _start = startOfDay(_start);
        _end = _endManuallySet ? endOfDay(_end) : endOfDay(_start);
        if (_end.isBefore(_start)) _end = endOfDay(_start);
      } else {
        _isAllDay = false;
        // Keep the (possibly changed) dates, restore the pre-toggle times of day.
        final startTime = _timedStart ?? DateTime.now();
        _start = DateTime(_start.year, _start.month, _start.day, startTime.hour, startTime.minute);
        final endTime = _timedEnd;
        if (_endManuallySet && endTime != null) {
          final candidate = DateTime(_end.year, _end.month, _end.day, endTime.hour, endTime.minute);
          _end = candidate.isAfter(_start) ? candidate : _start.add(_defaultDuration);
        } else {
          _end = _start.add(_defaultDuration);
        }
      }
    });
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    if (_isAllDay) {
      _applyStart(date);
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (time == null || !mounted) return;
    _applyStart(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _pickEnd() async {
    final firstDate = startOfDay(_start);
    final date = await showDatePicker(
      context: context,
      initialDate: _end.isBefore(firstDate) ? firstDate : _end,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    if (_isAllDay) {
      _applyEnd(date);
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_end),
    );
    if (time == null || !mounted) return;
    _applyEnd(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  // ---- Recurrence ----

  DateTime get _repeatUntil =>
      _repeatUntilOverride ??
      addMonthsClamped(startOfDay(_start), _defaultRepeatMonths[_recurrence] ?? 6);

  Future<void> _pickRepeatUntil() async {
    final firstDate = startOfDay(_start);
    final current = _repeatUntil;
    final date = await showDatePicker(
      context: context,
      initialDate: current.isBefore(firstDate) ? firstDate : current,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      helpText: 'Repeat until',
    );
    if (date == null || !mounted) return;
    setState(() => _repeatUntilOverride = startOfDay(date));
  }

  // ---- Submit ----

  List<Task> _buildTasks() {
    const uuid = Uuid();
    final createdAt = DateTime.now();
    final recurrenceId = _repeat ? uuid.v4() : null;
    var starts = _repeat ? recurrenceStarts(_start, _recurrence, _repeatUntil) : <DateTime>[_start];
    if (starts.isEmpty) starts = [_start];
    // Every occurrence ends the same number of days after it starts, at the
    // same wall-clock time as the first one (DST-safe "same duration").
    final endDayOffset = calendarDaysBetween(_start, _end);

    return [
      for (final start in starts)
        Task(
          taskId: uuid.v4(),
          createdAt: createdAt,
          startDate: start,
          endDate: _repeat
              ? DateTime(start.year, start.month, start.day + endDayOffset, _end.hour,
                  _end.minute, _end.second)
              : _end,
          dateCompleted: DateTime(2100),
          isAllDay: _isAllDay,
          highPriority: _highPriority,
          taskNotes: _taskNotes,
          taskText: _title,
          trainerId: widget.trainerId,
          threadId: _threadId,
          folderId: _selectedFolderId ?? '',
          isCompleted: false,
          recurrence: _repeat ? _recurrence : null,
          recurrenceId: recurrenceId,
        ),
    ];
  }

  static Future<void> _scheduleReminders(List<Task> tasks) async {
    // Occurrences past the reminder window get scheduled by the next launch's resync.
    final windowEnd = DateTime.now().add(NotificationService.reminderWindow);
    for (final task in tasks) {
      if (task.startDate.isAfter(windowEnd)) break;
      try {
        await NotificationService.scheduleTaskReminders(task);
      } catch (e) {
        debugPrint('Failed to schedule reminders for ${task.taskId}: $e');
      }
    }
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    if (_end.isBefore(_start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The end can\'t be before the start.')),
      );
      return;
    }
    form.save();
    setState(() => _isLoading = true);

    final tasks = _buildTasks();
    try {
      debugPrint('Inserting ${tasks.length} task row(s)');
      await Supabase.instance.client
          .from('task_table')
          .insert(tasks.map((t) => t.toInsertJson()).toList());
    } catch (e) {
      debugPrint('Supabase insert error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: $e')),
      );
      return;
    }

    // Only schedule reminders once the rows exist; don't make the user wait on it.
    unawaited(_scheduleReminders(tasks));

    if (!mounted) return;
    setState(() => _isLoading = false);
    widget.onSubmit(tasks.first);
  }

  // ---- UI ----

  String _formatDate(DateTime d) => MaterialLocalizations.of(context).formatShortDate(d);

  String _formatTime(DateTime d) => MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(d),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );

  String _formatMoment(DateTime d) =>
      _isAllDay ? _formatDate(d) : '${_formatDate(d)}\n${_formatTime(d)}';

  Widget _buildRepeatUntilTile() {
    final until = _repeatUntil;
    final count = recurrenceStarts(_start, _recurrence, until,
            maxCount: kMaxRecurrenceOccurrences + 1)
        .length;
    final countText = count > kMaxRecurrenceOccurrences
        ? 'Limited to $kMaxRecurrenceOccurrences occurrences'
        : '$count occurrence${count == 1 ? '' : 's'}';
    return ListTile(
      title: const Text('Repeat until'),
      subtitle: Text('${_formatDate(until)}\n$countText'),
      trailing: const Icon(Icons.event_repeat),
      onTap: _pickRepeatUntil,
    );
  }

  @override
  Widget build(BuildContext context) {
    final endBeforeStart = _end.isBefore(_start);
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
        backgroundColor: Colors.redAccent,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Enter a title' : null,
                onSaved: (value) => _title = value ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start'),
                      subtitle: Text(_formatMoment(_start)),
                      onTap: _pickStart,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End'),
                      subtitle: Text(
                        endBeforeStart
                            ? '${_formatMoment(_end)}\nBefore start'
                            : _formatMoment(_end),
                        style: endBeforeStart ? TextStyle(color: errorColor) : null,
                      ),
                      onTap: _pickEnd,
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('All Day'),
                value: _isAllDay,
                onChanged: _setAllDay,
              ),
              SwitchListTile(
                title: const Text('Repeat'),
                value: _repeat,
                onChanged: (val) => setState(() => _repeat = val),
              ),
              if (_repeat) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: [
                        for (final entry in kRecurrenceLabels.entries)
                          ButtonSegment<String>(value: entry.key, label: Text(entry.value)),
                      ],
                      selected: {_recurrence},
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: Colors.redAccent,
                        selectedForegroundColor: Colors.white,
                      ),
                      onSelectionChanged: (selection) => setState(() {
                        _recurrence = selection.first;
                      }),
                    ),
                  ),
                ),
                _buildRepeatUntilTile(),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('High Priority'),
                value: _highPriority,
                onChanged: (val) => setState(() => _highPriority = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Task Notes'),
                maxLines: 2,
                onSaved: (value) => _taskNotes = value ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Folder'),
                value: _selectedFolderId,
                items: _folders.map((folder) {
                  return DropdownMenuItem<String>(
                    value: folder['folder_id'].toString(),
                    child: Text(folder['folder_name'] ?? folder['folder_id'].toString()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedFolderId = val),
                // No validator, folder is optional
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
