import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poketask/services/ability_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task.dart';
import 'sfx_service.dart';
import 'task_completion_service.dart';
import 'notification_service.dart';

class TaskDetailsCard extends StatefulWidget {
  final Task task;
  const TaskDetailsCard({super.key, required this.task});

  @override
  State<TaskDetailsCard> createState() => _TaskDetailsCardState();
}

class _TaskDetailsCardState extends State<TaskDetailsCard> {
  late bool isCompleted;
  // Tasks with a completion save in flight. Static so reopening the card while
  // the previous save is running can't toggle the task (and its XP) again.
  static final Set<String> _completionsInFlight = <String>{};
  final SfxService _sfx = SfxService(); // first access preloads the chime
  late String notes;
  final TextEditingController _notesController = TextEditingController();
  bool _savingDates = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.task.isCompleted;
    notes = widget.task.taskNotes;
    _notesController.text = notes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Optimistic: the checkmark (and chime) flip immediately, then the task and
  /// XP rewards are saved by [TaskCompletionService]. If the task row can't be
  /// saved the state is reverted. Celebration dialogs show after the writes.
  Future<void> updateTaskCompleted(bool completed) async {
    final task = widget.task;
    // Ignore double taps while saving.
    if (!_completionsInFlight.add(task.taskId)) return;
    final now = DateTime.now();
    final previousDateCompleted = task.dateCompleted;
    // Captured before any await: the user may close this card while rewards
    // are still saving, and level-up/ability dialogs should still appear.
    final messenger = ScaffoldMessenger.maybeOf(context);
    final dialogContext = Navigator.of(context, rootNavigator: true).context;

    void applyState(bool value, DateTime dateCompleted) {
      isCompleted = value;
      task.isCompleted = value;
      task.dateCompleted = dateCompleted;
    }

    setState(() => applyState(completed, completed ? now : DateTime(2100)));
    _syncTaskReminders(completed);
    if (completed) unawaited(_sfx.playTaskComplete());

    final TaskCompletionResult result;
    try {
      result = await TaskCompletionService.setCompleted(
        task: task,
        completed: completed,
        now: now,
      );
    } catch (e) {
      debugPrint('updateTaskCompleted: saving task failed: $e');
      if (mounted) {
        setState(() => applyState(!completed, previousDateCompleted));
      } else {
        applyState(!completed, previousDateCompleted);
      }
      _syncTaskReminders(!completed);
      if (messenger != null && messenger.mounted) {
        messenger.showSnackBar(const SnackBar(
          content: Text("Couldn't update the task. Please try again."),
        ));
      }
      return;
    } finally {
      _completionsInFlight.remove(task.taskId);
    }

    if (result.rewardsFailed && messenger != null && messenger.mounted) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Task saved, but XP rewards could not be updated.'),
      ));
    }
    final newPokemon = result.newPokemon;
    if (newPokemon != null && dialogContext.mounted) {
      await showNewPokemonDialog(
        dialogContext,
        '${newPokemon['pokemon_name']}',
        '${newPokemon['type']}',
      );
    }
    if (result.pokemonLevelUps.isNotEmpty && dialogContext.mounted) {
      await showDialog<void>(
        context: dialogContext,
        builder: (context) => AlertDialog(
          title: const Text('Pokémon Leveled Up!'),
          content: Text(result.pokemonLevelUps.join('\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    // Ability offers, one at a time, with a short beat between dialogs.
    for (final offer in result.abilityOffers) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!dialogContext.mounted) return;
      await offerAbilityDialog(
        context: dialogContext,
        ability: offer.ability,
        pokeId: offer.pokeId,
        currentAbilityIds: offer.currentAbilityIds,
      );
    }
  }

  /// Fire-and-forget: completed tasks lose their reminders, reopened ones get
  /// them back. NotificationService never throws.
  void _syncTaskReminders(bool completed) {
    if (completed) {
      unawaited(NotificationService.cancelTaskReminders(widget.task.taskId));
    } else {
      unawaited(NotificationService.scheduleTaskReminders(widget.task));
    }
  }

  Future<void> updateTaskNotes(String notes) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('task_table')
        .update({'task_notes': notes})
        .eq('task_id', widget.task.taskId);
  }

  // ---- Start/end editing ----

  String _formatDateTime(DateTime d) {
    final date = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (widget.task.isAllDay) return date;
    return '$date ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  // Whole calendar days between two dates (DST-safe).
  int _daysBetween(DateTime from, DateTime to) {
    return DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;
  }

  // Date picker, then a time picker unless the task is all-day.
  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final minDate = DateTime(2000);
    final maxDate = DateTime(2100, 12, 31);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial.isBefore(minDate) ? initial : minDate,
      lastDate: initial.isAfter(maxDate) ? initial : maxDate,
    );
    if (pickedDate == null || !mounted) return null;
    if (widget.task.isAllDay) return pickedDate;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) return null;
    return DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
        pickedTime.hour, pickedTime.minute);
  }

  Future<void> _editStartDate() async {
    final task = widget.task;
    final picked = await _pickDateTime(task.startDate);
    if (picked == null || !mounted) return;
    DateTime newStart;
    DateTime newEnd;
    if (task.isAllDay) {
      // Keep the same number of days, snapped to day boundaries.
      final spanDays = _daysBetween(task.startDate, task.endDate);
      newStart = startOfDay(picked);
      newEnd = endOfDay(DateTime(newStart.year, newStart.month,
          newStart.day + (spanDays < 0 ? 0 : spanDays)));
    } else {
      // Shift the end so the task keeps its original duration.
      final duration = task.endDate.difference(task.startDate);
      newStart = picked;
      newEnd = picked.add(duration.isNegative ? Duration.zero : duration);
    }
    await _saveTaskDates(newStart, newEnd);
  }

  Future<void> _editEndDate() async {
    final task = widget.task;
    final picked = await _pickDateTime(task.endDate);
    if (picked == null || !mounted) return;
    final newEnd = task.isAllDay ? endOfDay(picked) : picked;
    if (newEnd.isBefore(task.startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End can\'t be before the start.')),
      );
      return;
    }
    await _saveTaskDates(task.startDate, newEnd);
  }

  Future<void> _saveTaskDates(DateTime newStart, DateTime newEnd) async {
    final task = widget.task;
    final oldStart = task.startDate;
    final oldEnd = task.endDate;
    if (newStart == oldStart && newEnd == oldEnd) return;
    setState(() {
      _savingDates = true;
      task.startDate = newStart;
      task.endDate = newEnd;
    });
    try {
      await Supabase.instance.client
          .from('task_table')
          .update({
            'start_date': newStart.toIso8601String(),
            'end_date': newEnd.toIso8601String(),
          })
          .eq('task_id', task.taskId);
    } catch (e) {
      debugPrint('❌ Failed to update task dates: $e');
      task.startDate = oldStart;
      task.endDate = oldEnd;
      if (!mounted) return;
      setState(() => _savingDates = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t update the task dates. Please try again.')),
      );
      return;
    }
    if (mounted) setState(() => _savingDates = false);
    // Fire-and-forget: never throws, and the UI shouldn't wait on it.
    NotificationService.scheduleTaskReminders(task);
  }

  Widget _buildDateRow({
    required String label,
    required DateTime value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20),
      title: Text(label),
      subtitle: Text(_formatDateTime(value)),
      trailing: Icon(Icons.edit, size: 18),
      enabled: !_savingDates,
      onTap: onTap,
    );
  }

  // ---- Delete ----

  Future<void> _deleteTask() async {
    final task = widget.task;
    String? scope = 'single';
    if (task.isRecurring) {
      scope = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Delete recurring task'),
          content: Text('"${task.taskText}" is part of a recurring series.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('single'),
              child: Text('Delete this task only', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('following'),
              child: Text('Delete this and all following', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
      if (scope == null || !mounted) return;
    }
    setState(() => _deleting = true);
    final supabase = Supabase.instance.client;
    final deletedIds = <String>{task.taskId};
    try {
      if (scope == 'following') {
        final fromStart = task.startDate.toIso8601String();
        // Collect the ids first so their reminders can be cancelled.
        final rows = await supabase
            .from('task_table')
            .select('task_id')
            .eq('recurrence_id', task.recurrenceId!)
            .gte('start_date', fromStart);
        deletedIds.addAll(rows.map((r) => r['task_id'].toString()));
        await supabase
            .from('task_table')
            .delete()
            .eq('recurrence_id', task.recurrenceId!)
            .gte('start_date', fromStart);
      } else {
        await supabase
            .from('task_table')
            .delete()
            .eq('task_id', task.taskId);
      }
    } catch (e) {
      debugPrint('❌ Failed to delete task: $e');
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t delete the task. Please try again.')),
      );
      return;
    }
    for (final id in deletedIds) {
      NotificationService.cancelTaskReminders(id);
    }
    if (!mounted) return;
    Navigator.of(context).pop('delete');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.task.highPriority == true)
            Container(
              color: Colors.red[700],
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.priority_high, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'High Priority',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.task.endDate.isBefore(DateTime.now()))
            Container(
              color: Colors.orange[800],
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Past Deadline',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: Text(widget.task.taskText)),
                IconButton(
                  icon: Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                  tooltip: isCompleted ? 'Completed' : 'Mark as complete',
                  onPressed: () async {
                    await updateTaskCompleted(!isCompleted);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notes:'),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add notes...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.save),
                  tooltip: 'Save Notes',
                  onPressed: () async {
                    setState(() {
                      notes = _notesController.text;
                      widget.task.taskNotes = notes;
                    });
                    await updateTaskNotes(notes);
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            _buildDateRow(
              label: widget.task.isAllDay ? 'Start (all day)' : 'Start',
              value: widget.task.startDate,
              icon: Icons.play_circle_outline,
              onTap: _editStartDate,
            ),
            _buildDateRow(
              label: widget.task.isAllDay ? 'End (all day)' : 'End',
              value: widget.task.endDate,
              icon: Icons.flag_outlined,
              onTap: _editEndDate,
            ),
            if (widget.task.isRecurring)
              Text(
                'Date changes apply to this occurrence only.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            SizedBox(height: 8),
            Text('Completed: ${isCompleted ? "Yes" : "No"}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(isCompleted),
          child: Text('Close'),
        ),
        TextButton(
          onPressed: _deleting ? null : _deleteTask,
          child: Text('Delete', style: TextStyle(color: _deleting ? Colors.grey : Colors.red)),
        ),
      ],
    );
  }
}
