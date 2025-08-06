import 'package:flutter/material.dart';
import 'homepage.dart';
import '../services/my_scaffold.dart';
import 'threads_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TasksPage extends StatefulWidget {
  final String trainerId;
  const TasksPage({super.key, required this.trainerId});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int totalTasksCompleted = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCompletedTasks();
  }

  Future<void> fetchCompletedTasks() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('trainer_table')
        .select('completed_tasks')
        .eq('trainer_id', widget.trainerId)
        .maybeSingle();
    setState(() {
      totalTasksCompleted = response != null && response['completed_tasks'] != null
          ? response['completed_tasks'] as int
          : 0;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: MyScaffold(
        selectedIndex: 1, // Tasks tab index is 1
        trainerId: widget.trainerId,
        child: Container(// Background color behind everything
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.earbuds_rounded,
                          size: 100,
                          color: Colors.redAccent,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/threads',
                              arguments: {'trainer_id': widget.trainerId},
                            );
                          },
                          child: Text('Go to Threads'),
                        ),
                        SizedBox(height: 20),
                        isLoading
                            ? CircularProgressIndicator()
                            : Text('Total Tasks Completed: $totalTasksCompleted',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  flex: 1,
                ),
                Container(
                  color: Colors.yellow[700],
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      'Total Tasks Completed: $totalTasksCompleted',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333), // Dark text color
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder,
                          size: 100,
                          color: Colors.redAccent,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/folders',
                              arguments: {'trainer_id': widget.trainerId},
                            );
                          },
                          child: Text('Go to Folders'),
                        ),
                      ],
                    ),
                  ),
                  flex: 1,
                ),
              ],
            ),

          ),
        ), // Background color behind everything
      )
    );
  }
}
