import 'package:flutter/material.dart';
import 'homepage.dart';
import '../services/my_scaffold.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      selectedIndex: 1,
      child: Center(child: Text('Calendar')),
    );
  }
}
