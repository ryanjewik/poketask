import 'package:flutter/material.dart';
import 'homepage.dart';
import '../services/my_scaffold.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      selectedIndex: 4,
      child: Center(child: Text('Help Page')),
    );
  }
}
