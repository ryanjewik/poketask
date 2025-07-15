import 'package:flutter/material.dart';
import 'package:poketask/pages/taskspage.dart';
import 'package:poketask/pages/threads_page.dart';
import 'package:poketask/pages/folders_page.dart';
import 'pages/homepage.dart';
import 'pages/pokebattle_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //showPerformanceOverlay: true,
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
      initialRoute: 'home',
        routes: {
        'home': (context) => const MyHomePage(title: 'PokeTask Home Page'),
        'calendar': (context) => const MyHomePage(title: 'PokeTask Calendar'),
        'tasks': (context) => const TasksPage(),
        '/threads': (context) => const ThreadsPage(),
        '/folders': (context) => const FoldersPage(),
        '/pokebattle': (context) => const PokebattlePage(),
        }
    );
  }
}
