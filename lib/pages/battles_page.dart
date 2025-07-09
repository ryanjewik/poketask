import 'package:flutter/material.dart';
import 'homepage.dart';
import '../services/my_scaffold.dart';

class BattlesPage extends StatelessWidget {
  const BattlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      selectedIndex: 4,
      child: Center(child: Text('Battles Page')),
    );
  }
}
