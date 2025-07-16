import 'package:flutter/material.dart';

class PokebattlePage extends StatelessWidget {
  final String trainerId;
  const PokebattlePage({super.key, required this.trainerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PokéBattle'),
        backgroundColor: Colors.redAccent,
      ),
      body: const Center(
        child: Text(
          'PokéBattle Page',
          style: TextStyle(fontSize: 28, color: Colors.amber, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
