import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/task.dart';

class TaskForm extends StatefulWidget {
  final void Function(Task) onSubmit;
  final String trainerId;
  final String? threadId;
  const TaskForm({super.key, required this.onSubmit, required this.trainerId, this.threadId});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(Duration(hours: 1));
  bool _isAllDay = false;
  bool _highPriority = false;
  String _taskNotes = '';
  String? _selectedFolderId;
  List<Map<String, dynamic>> _folders = [];
  bool _isLoading = false;
  late String _threadId;

  @override
  void initState() {
    super.initState();
    _threadId = widget.threadId ?? '';
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('folder_table')
          .select()
          .eq('trainer_id', widget.trainerId);
      if (response != null) {
        setState(() {
          _folders = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) => value == null || value.isEmpty ? 'Enter a title' : null,
              onSaved: (value) => _title = value ?? '',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Start'),
                    subtitle: Text('${_start.toLocal()}'.split('.')[0]),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _start,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_start),
                        );
                        if (time != null) {
                          setState(() {
                            _start = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('End'),
                    subtitle: Text('${_end.toLocal()}'.split('.')[0]),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _end,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_end),
                        );
                        if (time != null) {
                          setState(() {
                            _end = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: Text('All Day'),
              value: _isAllDay,
              onChanged: (val) => setState(() => _isAllDay = val),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('High Priority'),
              value: _highPriority,
              onChanged: (val) => setState(() => _highPriority = val),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: 'Task Notes'),
              maxLines: 2,
              onSaved: (value) => _taskNotes = value ?? '',
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Folder'),
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  setState(() { _isLoading = true; });
                  final uuid = Uuid();
                  final newTask = Task(
                    taskId: uuid.v4(),
                    createdAt: DateTime.now(),
                    startDate: _start,
                    endDate: _end,
                    dateCompleted: DateTime(2100),
                    isAllDay: _isAllDay,
                    highPriority: _highPriority,
                    taskNotes: _taskNotes,
                    taskText: _title,
                    trainerId: widget.trainerId,
                    threadId: _threadId,
                    folderId: _selectedFolderId ?? '',
                    isCompleted: false,
                  );
                  // Prepare values for insert, using null for empty UUIDs
                  final insertMap = {
                    'task_id': newTask.taskId,
                    'created_at': newTask.createdAt.toIso8601String(),
                    'start_date': newTask.startDate.toIso8601String(),
                    'end_date': newTask.endDate.toIso8601String(),
                    'date_completed': newTask.dateCompleted.toIso8601String(),
                    'is_all_day': newTask.isAllDay,
                    'high_priority': newTask.highPriority,
                    'task_notes': newTask.taskNotes,
                    'task_text': newTask.taskText,
                    'trainer_id': newTask.trainerId,
                    'thread_id': (_threadId.isEmpty) ? null : _threadId,
                    'folder_id': (_selectedFolderId == null || _selectedFolderId!.isEmpty) ? null : _selectedFolderId,
                    'is_completed': newTask.isCompleted,
                  };
                  debugPrint('Insert map: ' + insertMap.toString());
                  final supabase = Supabase.instance.client;
                  try {
                    final response = await supabase.from('task_table').insert(insertMap);
                    debugPrint('Supabase insert response: ' + response.toString());
                    setState(() { _isLoading = false; });
                    widget.onSubmit(newTask);
                  } catch (e) {
                    setState(() { _isLoading = false; });
                    debugPrint('Supabase insert error: ' + e.toString());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add task: ' + e.toString())),
                    );
                  }
                }
              },
              child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Add'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
