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
      from: DateTime.now().subtract(Duration(hours: 2)),
      to: DateTime.now().subtract(Duration(hours: 1)),
      notes: 'Go over the main features and deadlines.',
      threadId: 1,
      folderId: 1,
    ),
    Task(
      eventName: 'Review code',
      from: DateTime.now().add(Duration(hours: 2)),
      to: DateTime.now().add(Duration(hours: 3)),
      notes: 'Check the latest PRs and leave comments.',
      threadId: 1,
      isCompleted: true,
      folderId: 2,
    ),
    Task(
      eventName: 'Write documentation',
      from: DateTime.now().add(Duration(hours: 4)),
      to: DateTime.now().add(Duration(hours: 5)),
      notes: 'Document the new API endpoints.',
      threadId: 1,
      folderId: 2,
    ),
    Task(
      eventName: 'Team meeting',
      from: DateTime.now().add(Duration(hours: 6)),
      to: DateTime.now().add(Duration(hours: 7)),
      notes: 'Weekly sync with the whole team.',
      threadId: 2,
      folderId: 3,
      highPriority: true,
    ),
    Task(
      eventName: 'design battle system',
      from: DateTime.now().subtract(Duration(hours: 2)),
      to: DateTime.now().subtract(Duration(hours: 1)),
      notes: 'how will the min max AI work',
      threadId: 1,
    ),
  ];
  Task? selectedTask;
  int? selectedThreadId;

  @override
  Widget build(BuildContext context) {
    // Gather all unique threadIds from tasks
    final List<int> threadIds = tasks.map((t) => t.threadId).where((id) => id != null).cast<int>().toSet().toList()..sort();
    final int? currentThreadId = selectedThreadId ?? (threadIds.isNotEmpty ? threadIds.first : null);
    final List<Task> currentThreadTasks = currentThreadId == null
        ? []
        : tasks.where((task) => task.threadId == currentThreadId).toList()..sort((a, b) => a.to.compareTo(b.to));
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
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),
                      Center(
                        child: Container(
                          width: 320,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.redAccent, width: 2),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down, color: Colors.redAccent, size: 32),
                              dropdownColor: Colors.white,
                              style: TextStyle(fontSize: 18, color: Colors.redAccent, fontWeight: FontWeight.bold),
                              hint: Text('Select a thread', style: TextStyle(fontSize: 18, color: Colors.redAccent)),
                              value: currentThreadId,
                              items: threadIds.map((int id) {
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Row(
                                    children: [
                                      Icon(Icons.earbuds_rounded, color: Colors.redAccent),
                                      SizedBox(width: 10),
                                      Text('Thread $id'),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  selectedThreadId = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 1),
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
                      if (currentThreadId != null && currentThreadTasks.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 16),
                          child: Text(
                            'Thread $currentThreadId Tasks',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32), // Increased font size
                          ),
                        ),
                      SizedBox(height: 12),
                      Container(
                        height: 380,
                        width: 280,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: currentThreadTasks.length * 2 - 1,
                          itemBuilder: (context, idx) {
                            if (idx.isEven) {
                              int i = idx ~/ 2;
                              final task = currentThreadTasks[i];
                              return GestureDetector(
                                onTap: () {
                                  _handleTaskTap(task);
                                },
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.8, end: 1.0),
                                  duration: Duration(milliseconds: 400 + i * 80),
                                  curve: Curves.easeOutBack,
                                  builder: (context, scale, child) {
                                    return Transform.scale(
                                      scale: scale,
                                      child: child,
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (task.highPriority == true)
                                        Container(
                                          color: Colors.red[700],
                                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                          child: Row(
                                            children: [
                                              Icon(Icons.priority_high, color: Colors.white, size: 18),
                                              SizedBox(width: 6),
                                              Text(
                                                'High Priority',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (task.to.isBefore(DateTime.now()))
                                        Container(
                                          color: Colors.orange[800],
                                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                          child: Row(
                                            children: [
                                              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                                              SizedBox(width: 6),
                                              Text(
                                                'Past Deadline',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Card(
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
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Center(
                                child: Icon(Icons.arrow_downward, color: Colors.redAccent, size: 28),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Add Task to Thread $currentThreadId'),
                        onPressed: () async {
                          final newTask = await showDialog<Task>(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SizedBox(
                                width: 350,
                                child: TaskForm(
                                  onSubmit: (task) {
                                    final taskWithThread = Task(
                                      eventName: task.eventName,
                                      from: task.from,
                                      to: task.to,
                                      isAllDay: task.isAllDay,
                                      background: task.background,
                                      threadId: currentThreadId!,
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
                    ],
                  ),
                ),
              ),
            );
          },
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