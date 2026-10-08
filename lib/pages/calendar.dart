import 'package:flutter/material.dart';
import '../services/task_details_card.dart';
import '../services/my_scaffold.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/task.dart';
import '../services/task_form.dart';
import '../services/notification_service.dart';
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

  // Whole calendar days between two dates (DST-safe).
  int _daysBetween(DateTime from, DateTime to) {
    return DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;
  }

  // Drag-and-drop: move the task to the drop time, keeping its duration.
  // TaskDataSource.convertAppointmentToObject hands back the untouched Task,
  // so details.appointment still carries the original dates here.
  void _onDragEnd(AppointmentDragEndDetails details) {
    final appointment = details.appointment;
    final droppingTime = details.droppingTime;
    if (appointment is! Task || droppingTime == null) return;
    final task = appointment;
    DateTime newStart;
    DateTime newEnd;
    if (task.isAllDay) {
      final spanDays = _daysBetween(task.startDate, task.endDate);
      newStart = startOfDay(droppingTime);
      newEnd = endOfDay(DateTime(newStart.year, newStart.month,
          newStart.day + (spanDays < 0 ? 0 : spanDays)));
    } else {
      final duration = task.endDate.difference(task.startDate);
      newStart = droppingTime;
      newEnd = droppingTime.add(duration.isNegative ? Duration.zero : duration);
    }
    _persistTaskDates(task, newStart, newEnd);
  }

  void _onAppointmentResizeEnd(AppointmentResizeEndDetails details) {
    final appointment = details.appointment;
    if (appointment is! Task) return;
    final task = appointment;
    DateTime newStart = details.startTime ?? task.startDate;
    DateTime newEnd = details.endTime ?? task.endDate;
    if (task.isAllDay) {
      newStart = startOfDay(newStart);
      newEnd = endOfDay(newEnd);
    }
    if (newEnd.isBefore(newStart)) {
      setState(() => _dataSource = TaskDataSource(_tasks));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End can\'t be before the start.')),
      );
      return;
    }
    _persistTaskDates(task, newStart, newEnd);
  }

  // Optimistically applies new dates, saves them, and reverts on failure.
  Future<void> _persistTaskDates(Task task, DateTime newStart, DateTime newEnd) async {
    final oldStart = task.startDate;
    final oldEnd = task.endDate;
    if (newStart == oldStart && newEnd == oldEnd) {
      // Dropped back in place (or an invalid drop): just resync the view.
      setState(() => _dataSource = TaskDataSource(_tasks));
      return;
    }
    setState(() {
      task.startDate = newStart;
      task.endDate = newEnd;
      _dataSource = TaskDataSource(_tasks);
    });
    try {
      await Supabase.instance.client
          .from('task_table')
          .update({
            'start_date': newStart.toIso8601String(),
            'end_date': newEnd.toIso8601String(),
          })
          .eq('task_id', task.taskId);
    } catch (e) {
      debugPrint('❌ Failed to move task ${task.taskId}: $e');
      task.startDate = oldStart;
      task.endDate = oldEnd;
      if (!mounted) return;
      setState(() => _dataSource = TaskDataSource(_tasks));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t move "${task.taskText}". Please try again.')),
      );
      return;
    }
    // Fire-and-forget: never throws.
    NotificationService.scheduleTaskReminders(task);
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
                onDragEnd: _onDragEnd,
                onAppointmentResizeEnd: _onAppointmentResizeEnd,
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
                      if (!mounted) return;
                      if (result == 'delete') {
                        // A recurring delete can remove many rows, so reload.
                        await _fetchTasksForTrainer(trainerId);
                      } else {
                        // Dates/completion may have been edited in place.
                        setState(() {
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
                    // A recurring task inserts many rows but onSubmit returns
                    // only the first, so reload everything.
                    await _fetchTasksForTrainer(trainerId);
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

  // Required for drag/resize with custom objects. Returns the Task unchanged:
  // CalendarPage applies, persists (and on failure reverts) the new dates in
  // onDragEnd/onAppointmentResizeEnd, which need the original dates.
  @override
  dynamic convertAppointmentToObject(dynamic customData, Appointment appointment) {
    return customData;
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
