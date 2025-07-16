import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/task.dart';
import '../services/task_details_card.dart';
import '../services/task_form.dart';

class ThreadsPage extends StatefulWidget {
  const ThreadsPage({super.key, required this.trainerId});
  final String trainerId;
  @override
  State<ThreadsPage> createState() => _ThreadsPageState();
}

class _ThreadsPageState extends State<ThreadsPage> {

  Task? selectedTask;
  String? selectedThreadId;
  List<Task> threadTasks = [];
  Map<String, String> threadIdToName = {};

  @override
  void initState() {
    super.initState();
    fetchThreadTasks();
  }

  Future<void> fetchThreadTasks() async {
    final supabase = Supabase.instance.client;
    try {
      // Fetch all threads for the trainer
      final threadsResponse = await supabase
          .from('threads_table')
          .select('thread_id, thread_name')
          .eq('trainer_id', widget.trainerId);
      Map<String, String> idToName = {};
      List<String> allThreadIds = [];
      if (threadsResponse != null) {
        for (final thread in threadsResponse) {
          final id = thread['thread_id']?.toString() ?? '';
          if (id.isNotEmpty) {
            idToName[id] = thread['thread_name'] ?? id;
            allThreadIds.add(id);
          }
        }
      }
      // Fetch tasks as before
      final response = await supabase
          .from('task_table')
          .select()
          .eq('trainer_id', widget.trainerId)
          .not('thread_id', 'is', null);
      List<Task> fetchedTasks = [];
      if (response != null) {
        fetchedTasks = List<Task>.from(
          response.map((item) => Task.fromJson(item)),
        );
      }
      if (!mounted) return;
      setState(() {
        threadTasks = fetchedTasks;
        threadIdToName = idToName;
      });
    } catch (e) {
      debugPrint('❌ Failed to fetch thread tasks or thread names: $e');
    }
  }

  Future<String?> addThread(String threadName) async {
    final supabase = Supabase.instance.client;
    final uuid = Uuid();
    final threadId = uuid.v4();
    try {
      final response = await supabase
          .from('threads_table')
          .insert({
            'thread_id': threadId,
            'thread_name': threadName,
            'trainer_id': widget.trainerId,
          })
          .select('thread_id')
          .single();
      if (response != null && response['thread_id'] != null) {
        return response['thread_id'].toString();
      }
    } catch (e) {
      debugPrint('❌ Failed to add thread: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Use all thread IDs from threadIdToName for the dropdown
    final List<String> threadIds = threadIdToName.keys.toList()..sort();
    final String? dropdownValue = selectedThreadId;
    final List<Task> currentThreadTasks = (dropdownValue == null)
        ? []
        : threadTasks.where((task) => task.threadId == dropdownValue).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                width: 320,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.redAccent, width: 2),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    icon: Icon(Icons.arrow_drop_down, color: Colors.redAccent, size: 32),
                                    dropdownColor: Colors.white,
                                    style: TextStyle(fontSize: 18, color: Colors.redAccent, fontWeight: FontWeight.bold),
                                    hint: Text('Select a thread', style: TextStyle(fontSize: 18, color: Colors.redAccent)),
                                    value: dropdownValue,
                                    items: threadIds.map((String id) {
                                      final threadName = threadIdToName[id] ?? id;
                                      return DropdownMenuItem<String>(
                                        value: id,
                                        child: Row(
                                          children: [
                                            Icon(Icons.earbuds_rounded, color: Colors.redAccent),
                                            SizedBox(width: 10),
                                            Text(threadName),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedThreadId = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            _buildAddThreadButton(),
                          ],
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
                            title: Text(selectedTask!.taskText),
                            subtitle: Text(selectedTask!.taskNotes),
                            trailing: Text(
                              '${selectedTask!.startDate.hour.toString().padLeft(2, '0')}:${selectedTask!.startDate.minute.toString().padLeft(2, '0')} - '
                              '${selectedTask!.endDate.hour.toString().padLeft(2, '0')}:${selectedTask!.endDate.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      SizedBox(height: 18),
                      if (dropdownValue != null && currentThreadTasks.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 16),
                          child: Center(
                            child: Text(
                              threadIdToName[dropdownValue] != null
                                  ? '${threadIdToName[dropdownValue]} Tasks'
                                  : 'Thread Tasks',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      SizedBox(height: 12),
                      Container(
                        height: 380,
                        width: 280,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: currentThreadTasks.isEmpty ? 0 : currentThreadTasks.length * 2 - 1,
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
                                      if (task.endDate.isBefore(DateTime.now()))
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
                                          title: Text(task.taskText, style: TextStyle(fontSize: 15)),
                                          subtitle: Text(task.taskNotes, maxLines: 1, overflow: TextOverflow.ellipsis),
                                          trailing: Text(
                                            '${task.startDate.hour.toString().padLeft(2, '0')}:${task.startDate.minute.toString().padLeft(2, '0')} - '
                                            '${task.endDate.hour.toString().padLeft(2, '0')}:${task.endDate.minute.toString().padLeft(2, '0')}',
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
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Add Task to ${dropdownValue != null && threadIdToName[dropdownValue] != null ? threadIdToName[dropdownValue] : 'Thread'}'),
                        onPressed: () async {
                          final newTask = await showDialog<Task>(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SizedBox(
                                width: 350,
                                child: TaskForm(
                                  onSubmit: (task) {
                                    Navigator.of(context).pop(task);
                                  },
                                  trainerId: widget.trainerId,
                                  threadId: dropdownValue, // Pass the currently open threadId
                                ),
                              ),
                            ),
                          );
                          if (newTask != null) {
                            await fetchThreadTasks(); // Refresh the thread/task list from the database
                            if (mounted) {
                              setState(() {
                                selectedThreadId = dropdownValue; // Keep the current thread selected
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ), // <-- add this missing parenthesis to close SingleChildScrollView
            ); // <-- add this missing parenthesis to close LayoutBuilder
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
        threadTasks.remove(task);
      });
    } else {
      setState(() {
        // This will update the UI if isCompleted or notes changed
      });
    }
  }

  Widget _buildAddThreadButton() {
    return IconButton(
      icon: Icon(Icons.add_circle, color: Colors.redAccent, size: 32),
      tooltip: 'Add Thread',
      onPressed: () async {
        final threadNameController = TextEditingController();
        final newThreadId = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Add New Thread'),
            content: TextField(
              controller: threadNameController,
              decoration: InputDecoration(labelText: 'Thread Name'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = threadNameController.text.trim();
                  if (name.isNotEmpty) {
                    final threadId = await addThread(name);
                    Navigator.of(context).pop(threadId);
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
        );
        if (newThreadId != null) {
          await fetchThreadTasks();
          if (mounted) {
            setState(() {
              selectedThreadId = newThreadId;
            });
          }
        }
      },
    );
  }
}