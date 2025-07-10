import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../services/task_details_card.dart';
import '../services/task_form.dart';

class ThreadsPage extends StatefulWidget {
  const ThreadsPage({super.key});

  @override
  State<ThreadsPage> createState() => _ThreadsPageState();
}

class _ThreadsPageState extends State<ThreadsPage> {
  final List<Task> tasks = [
    Task(
      eventName: 'Discuss project requirements',
      from: DateTime.now(),
      to: DateTime.now().add(Duration(hours: 1)),
      notes: 'Go over the main features and deadlines.',
      threadId: 1
    ),
    Task(
      eventName: 'Review code',
      from: DateTime.now().add(Duration(hours: 2)),
      to: DateTime.now().add(Duration(hours: 3)),
      notes: 'Check the latest PRs and leave comments.',
      threadId: 1,
      isCompleted: true,
    ),
    Task(
      eventName: 'Write documentation',
      from: DateTime.now().add(Duration(hours: 4)),
      to: DateTime.now().add(Duration(hours: 5)),
      notes: 'Document the new API endpoints.',
      threadId: 1,
    ),
    Task(
      eventName: 'Team meeting',
      from: DateTime.now().add(Duration(hours: 6)),
      to: DateTime.now().add(Duration(hours: 7)),
      notes: 'Weekly sync with the whole team.',
      threadId: 2,
    ),
  ];
  Task? selectedTask;

  @override
  Widget build(BuildContext context) {
    // Filter tasks with threadId 1 and sort by 'to' attribute
    final List<Task> thread1Tasks = tasks
        .where((task) => task.threadId == 1)
        .toList()
      ..sort((a, b) => a.to.compareTo(b.to));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Threads'),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 100,
                  color: Colors.redAccent,
                ),
                SizedBox(height: 20),
                Text(
                  'Threads Page',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                DropdownButton<Task>(
                  hint: Text('Select a task'),
                  value: selectedTask,
                  items: tasks.map((Task task) {
                    return DropdownMenuItem<Task>(
                      value: task,
                      child: Text(task.eventName),
                    );
                  }).toList(),
                  onChanged: (Task? newValue) {
                    setState(() {
                      selectedTask = newValue;
                    });
                  },
                ),
                SizedBox(height: 20),
                if (selectedTask != null)
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    child: ListTile(
                      leading: Icon(
                        selectedTask!.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: selectedTask!.isCompleted ? Colors.green : Colors.grey,
                      ),
                      title: Text(selectedTask!.eventName),
                      subtitle: Text(selectedTask!.notes),
                      trailing: Text(
                        '${selectedTask!.from.hour.toString().padLeft(2, '0')}:${selectedTask!.from.minute.toString().padLeft(2, '0')} - '
                        '${selectedTask!.to.hour.toString().padLeft(2, '0')}:${selectedTask!.to.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                SizedBox(height: 32),
                if (thread1Tasks.isNotEmpty)
                  Column(
                    children: [
                      Text('Thread 1 Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Add Task to Thread 1'),
                        onPressed: () async {
                          final newTask = await showDialog<Task>(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SizedBox(
                                width: 350,
                                child: TaskForm(
                                  onSubmit: (task) {
                                    // Ensure the new task has threadId 1
                                    final taskWithThread = Task(
                                      eventName: task.eventName,
                                      from: task.from,
                                      to: task.to,
                                      isAllDay: task.isAllDay,
                                      background: task.background,
                                      threadId: 1,
                                      folderId: task.folderId,
                                      notes: task.notes,
                                      isCompleted: task.isCompleted,
                                    );
                                    Navigator.of(context).pop(taskWithThread);
                                  },
                                ),
                              ),
                            ),
                          );
                          if (newTask != null) {
                            setState(() {
                              tasks.add(newTask);
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 220, // Adjust as needed or make dynamic
                        width: 280,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: thread1Tasks.length * 2 - 1,
                          itemBuilder: (context, idx) {
                            if (idx.isEven) {
                              int i = idx ~/ 2;
                              final task = thread1Tasks[i];
                              return GestureDetector(
                                onTap: () {
                                  _handleTaskTap(task);
                                },
                                child: Card(
                                  color: Colors.white,
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    dense: true,
                                    leading: Icon(
                                      task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: task.isCompleted ? Colors.green : Colors.grey,
                                    ),
                                    title: Text(task.eventName, style: TextStyle(fontSize: 15)),
                                    subtitle: Text(task.notes, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    trailing: Text(
                                      '${task.from.hour.toString().padLeft(2, '0')}:${task.from.minute.toString().padLeft(2, '0')} - '
                                      '${task.to.hour.toString().padLeft(2, '0')}:${task.to.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Arrow between tasks
                              return Center(
                                child: Icon(Icons.arrow_downward, color: Colors.redAccent, size: 28),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTaskTap(Task task) async {
    final result = await showDialog(
      context: context,
      builder: (context) => TaskDetailsCard(task: task),
    );
    if (result == 'delete') {
      setState(() {
        tasks.remove(task);
      });
    } else {
      setState(() {
        // This will update the UI if isCompleted or notes changed
      });
    }
  }
}