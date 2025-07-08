import 'package:flutter/material.dart';
import 'pages/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poketask',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFFF0000), // Your exact color
          onPrimary: Colors.white,
          secondary: Colors.amber,
          onSecondary: Colors.black,
          error: Colors.red,
          onError: Colors.white,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black
        ),
        fontFamily: 'Fredoka', // default app font
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontFamily: 'PressStart2P', fontSize: 20),
          bodyMedium: TextStyle(fontFamily: 'Fredoka', fontSize: 14),
        ),
      ),
      home: const MyHomePage(title: 'PokeTask Home Page'),
    );
  }
}


