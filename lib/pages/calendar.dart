import 'package:flutter/material.dart';
import '../services/task_details_card.dart';
import '../services/my_scaffold.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/task.dart';
import '../services/task_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.trainerId});
  final String trainerId;
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late List<Task> _tasks;
  late TaskDataSource _dataSource;

  late String trainerId;

  @override
  void initState() {
    super.initState();
    trainerId = widget.trainerId;
    _tasks = [];
    _dataSource = TaskDataSource(_tasks);
    _fetchTasksForTrainer(trainerId);
  }

  Future<void> _fetchTasksForTrainer(String trainerId) async {
    final supabase = Supabase.instance.client;
    try {
      // Fetch all folders for the trainer
      final folderResponse = await supabase
          .from('folder_table')
          .select('folder_id, color')
          .eq('trainer_id', trainerId);
      // Build a folderId -> color map
      final Map<String, String> folderColorMap = {};
      if (folderResponse != null) {
        for (final folder in folderResponse) {
          final folderId = folder['folder_id']?.toString() ?? '';
          final colorString = folder['color']?.toString() ?? '';
          if (colorString.isNotEmpty) {
            folderColorMap[folderId] = colorString;
          }
        }
      }
      // Fetch tasks
      final response = await supabase
          .from('task_table')
          .select()
          .eq('trainer_id', trainerId);
      if (response != null) {
        if (!mounted) return;
        setState(() {
          _tasks = List<Task>.from(
            response.map((item) {
              final task = Task.fromJson(item);
              // Assign color hex string from folder map if available
              if (folderColorMap.containsKey(task.folderId)) {
                task.color = folderColorMap[task.folderId];
              }
              return task;
            }),
          );
          _dataSource = TaskDataSource(_tasks);
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch task or folder data: $e');
    }
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
      _dataSource = TaskDataSource(_tasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200], // Background color behind everything
      child: MyScaffold(
        selectedIndex: 0, // Calendar tab index is 0
        trainerId: trainerId,
        child: Stack(
          children: [
            Center(
              child: SfCalendar(
                view: CalendarView.week,
                allowDragAndDrop: true,
                allowAppointmentResize: true,
                allowViewNavigation: true,
                showNavigationArrow: true,
                backgroundColor: Colors.transparent, // Let parent container handle background
                dataSource: _dataSource,
                monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
                headerStyle: CalendarHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor: Color(0xFFFF0000), // Match MyScaffold red
                  textStyle: TextStyle(
                    color: Colors.white, // White text
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                appointmentBuilder: (context, details) {
                  final Task task = details.appointments.first as Task;
                  return GestureDetector(
                    onTap: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => TaskDetailsCard(task: task),
                      );
                      if (result == 'delete') {
                        setState(() {
                          _tasks.removeWhere((t) => t.taskId == task.taskId);
                          _dataSource = TaskDataSource(_tasks);
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _colorFromHex(task.color),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.all(3),
                      child: Text(
                        task.eventName,
                        style: TextStyle(
                          color: Color(0xFF353535), // Black text for contrast
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 3, // Show up to 3 lines before ellipsis
                        softWrap: true,
                        overflow: TextOverflow.ellipsis, // Show ... only if no space left
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 32,
              right: 32,
              child: FloatingActionButton(
                onPressed: () async {
                  final newTask = await showModalBottomSheet<Task>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent, // Make modal background transparent
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (modalContext) => LayoutBuilder(
                      builder: (context, constraints) {
                        return MediaQuery.removeViewInsets(
                          removeBottom: true,
                          context: context,
                          child: SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height * 0.9,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom,
                                  left: 16, right: 16, top: 24),
                                child: TaskForm(
                                  onSubmit: (task) {
                                    Navigator.of(modalContext).pop(task);
                                  },
                                  trainerId: trainerId,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                  if (newTask != null) {
                    _addTask(newTask);
                  }
                },
                backgroundColor: Color(0xFFFF0000),
                child: Icon(Icons.add, color: Colors.white),
                tooltip: 'Add Event',
              ),
            ),
          ],
        ),
      ),
    );
  }


}

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Task> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startDate;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endDate;
  }

  @override
  String getSubject(int index) {
    return appointments![index].taskText;
  }

  @override
  Color getColor(int index) {
    final Task task = appointments![index] as Task;
    // Use parsed color from hex, fallback to redAccent if null or invalid
    return _colorFromHex(task.color) ?? Colors.redAccent;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

Color _colorFromHex(String? hexColor) {
  if (hexColor == null || hexColor.isEmpty) return Colors.redAccent;
  String hex = hexColor.replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex'; // add alpha if missing
  try {
    return Color(int.parse('0x$hex'));
  } catch (_) {
    return Colors.redAccent;
  }
}
