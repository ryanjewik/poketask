import 'package:flutter/material.dart';
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
    notes = widget.task.notes;
    _notesController.text = notes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(widget.task.eventName)),
          IconButton(
            icon: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.green : Colors.grey,
            ),
            tooltip: isCompleted ? 'Completed' : 'Mark as complete',
            onPressed: () {
              setState(() {
                isCompleted = !isCompleted;
                widget.task.isCompleted = isCompleted;
              });
            },
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
                  onPressed: () {
                    setState(() {
                      notes = _notesController.text;
                      widget.task.notes = notes;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            Text('From: '
                '${widget.task.from.year}-${widget.task.from.month.toString().padLeft(2, '0')}-${widget.task.from.day.toString().padLeft(2, '0')} '
                '${widget.task.from.hour.toString().padLeft(2, '0')}:${widget.task.from.minute.toString().padLeft(2, '0')}'),
            Text('To: '
                '${widget.task.to.year}-${widget.task.to.month.toString().padLeft(2, '0')}-${widget.task.to.day.toString().padLeft(2, '0')} '
                '${widget.task.to.hour.toString().padLeft(2, '0')}:${widget.task.to.minute.toString().padLeft(2, '0')}'),
            SizedBox(height: 8),
            Text('Thread ID: ${widget.task.threadId}'),
            Text('Folder ID: ${widget.task.folderId}'),
            Text('Completed: ${isCompleted ? "Yes" : "No"}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop('delete');
          },
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
