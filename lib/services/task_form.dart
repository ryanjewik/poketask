import 'package:flutter/material.dart';
import '../../models/task.dart';

class TaskForm extends StatefulWidget {
  final void Function(Task) onSubmit;
  const TaskForm({super.key, required this.onSubmit});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(Duration(hours: 1));
  bool _isAllDay = false;

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
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  widget.onSubmit(Task(
                    eventName: _title,
                    from: _start,
                    to: _end,
                    isAllDay: _isAllDay,
                  ));
                }
              },
              child: Text('Add'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

