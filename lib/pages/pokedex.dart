import 'package:flutter/material.dart';
import '../services/my_scaffold.dart';
import 'homepage.dart';

class PokedexPage extends StatelessWidget {
  const PokedexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      selectedIndex: 0,
      child: Center(child: Text('Settings Page')),
    );
  }
}
