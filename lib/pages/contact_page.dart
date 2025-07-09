import 'package:flutter/material.dart';
import 'homepage.dart';
import '../services/my_scaffold.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      selectedIndex: 3,
      child: Center(child: Text('Contact Page')),
    );
  }
}
