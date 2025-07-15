import 'package:flutter/material.dart';

class PokebattlePage extends StatelessWidget {
  const PokebattlePage({super.key});

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

