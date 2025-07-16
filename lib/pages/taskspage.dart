import 'package:flutter/material.dart';
import 'homepage.dart';
import '../services/my_scaffold.dart';
import 'threads_page.dart';

class TasksPage extends StatelessWidget {
  final String trainerId;
  const TasksPage({super.key, required this.trainerId});

  @override
  Widget build(BuildContext context) {
    int totalTasksCompleted = 0; // This will eventually come from the database
    return Container(
      color: Colors.grey[200],
      child: MyScaffold(
        selectedIndex: 1, // Tasks tab index is 1
        trainerId: trainerId,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ThreadsPage(trainerId: trainerId),
                              ),
                            );
                          },
                          child: Text('Go to Threads'),
                        ),
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
                            Navigator.pushNamed(context, '/folders');
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
