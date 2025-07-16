import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:poketask/pages/calendar.dart';
import 'package:poketask/pages/pokedex.dart';
import 'package:poketask/pages/taskspage.dart';
import 'package:poketask/pages/threads_page.dart';
import 'package:poketask/pages/folders_page.dart';
import 'pages/homepage.dart';
import 'pages/pokebattle_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';


final supabaseUrl = dotenv.env['SUPABASE_URL'];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  // Optional: Run a simple query to test connection
  final supabase = Supabase.instance.client;
  runApp(MyApp());
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
      home: MyHomePage(title: 'PokeTask Home Page', trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
      initialRoute: 'home',
      routes: {
        'home': (context) => MyHomePage(title: 'PokeTask Home Page', trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        'calendar': (context) => CalendarPage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        'tasks': (context) => TasksPage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        '/threads': (context) => ThreadsPage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        '/folders': (context) => FoldersPage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        'pokebattle': (context) => PokebattlePage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        'pokedex': (context) => PokedexPage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),

      }
    );
  }
}
