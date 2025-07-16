import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task.dart';

class TaskDetailsCard extends StatefulWidget {
  final Task task;
  const TaskDetailsCard({super.key, required this.task});

  @override
  State<TaskDetailsCard> createState() => _TaskDetailsCardState();
}

class _TaskDetailsCardState extends State<TaskDetailsCard> {
  late bool isCompleted;
  late String notes;
  final TextEditingController _notesController = TextEditingController();

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

  Future<void> updateTaskCompleted(bool completed) async {
    final supabase = Supabase.instance.client;
    final now = DateTime.now();
    await supabase
        .from('task_table')
        .update({
          'is_completed': completed,
          'date_completed': completed ? now.toIso8601String() : null,
        })
        .eq('task_id', widget.task.taskId);

    // Update completed_tasks for the trainer
    final trainerId = widget.task.trainerId;
    if (trainerId != null && trainerId.isNotEmpty) {
      // Get current completed_tasks value
      final trainerResponse = await supabase
        .from('trainer_table')
        .select('completed_tasks')
        .eq('trainer_id', trainerId)
        .maybeSingle();
      int completedTasks = (trainerResponse != null && trainerResponse['completed_tasks'] != null)
        ? trainerResponse['completed_tasks'] as int
        : 0;
      // Increment or decrement
      final newCompletedTasks = completed
        ? completedTasks + 1
        : (completedTasks > 0 ? completedTasks - 1 : 0);
      await supabase
        .from('trainer_table')
        .update({'completed_tasks': newCompletedTasks})
        .eq('trainer_id', trainerId);
    }

    setState(() {
      isCompleted = completed;
      widget.task.isCompleted = completed;
      widget.task.dateCompleted = completed ? now : DateTime(2100);
    });
    // Do not close the dialog here
  }

  Future<void> updateTaskNotes(String notes) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('task_table')
        .update({'task_notes': notes})
        .eq('task_id', widget.task.taskId);
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
            Text('Start: '
                '${widget.task.startDate.year}-${widget.task.startDate.month.toString().padLeft(2, '0')}-${widget.task.startDate.day.toString().padLeft(2, '0')} '
                '${widget.task.startDate.hour.toString().padLeft(2, '0')}:${widget.task.startDate.minute.toString().padLeft(2, '0')}'),
            Text('End: '
                '${widget.task.endDate.year}-${widget.task.endDate.month.toString().padLeft(2, '0')}-${widget.task.endDate.day.toString().padLeft(2, '0')} '
                '${widget.task.endDate.hour.toString().padLeft(2, '0')}:${widget.task.endDate.minute.toString().padLeft(2, '0')}'),
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
          onPressed: () async {
            final supabase = Supabase.instance.client;
            await supabase
                .from('task_table')
                .delete()
                .eq('task_id', widget.task.taskId);
            Navigator.of(context).pop('delete');
          },
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
