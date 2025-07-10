import 'package:flutter/material.dart';
import 'homepage.dart';
import '../services/my_scaffold.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/task.dart';
import '../services/task_form.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late List<Task> _tasks;
  late TaskDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _tasks = _getDataSource();
    _dataSource = TaskDataSource(_tasks);
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
                  return Container(
                    decoration: BoxDecoration(
                      color: task.background,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        left: 16, right: 16, top: 24),
                      child: TaskForm(
                        onSubmit: (task) {
                          Navigator.of(context).pop(task);
                        },
                      ),
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

  List<Task> _getDataSource() {
    final List<Task> tasks = <Task>[];
    final DateTime today = DateTime.now();
    final DateTime startTime =
    DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    tasks.add(
        Task(eventName: 'Conference', from: startTime, to: endTime));
    return tasks;
  }
}

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Task> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
