import 'package:flutter/material.dart';
import '../services/my_scaffold.dart';

class PokemonPage extends StatelessWidget {
  const PokemonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Squirtle'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/sprites/squirtle.png', width: 150, height: 150),
            const SizedBox(height: 16),
            const Text('This is Squirtle!', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
