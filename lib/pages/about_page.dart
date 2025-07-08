import 'package:flutter/material.dart';
import 'homepage.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      selectedIndex: 1,
      child: Center(child: Text('About Page')),
    );
  }
}

