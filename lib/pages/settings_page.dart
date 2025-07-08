import 'package:flutter/material.dart';
import 'homepage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      selectedIndex: 0,
      child: Center(child: Text('Settings Page')),
    );
  }
}

