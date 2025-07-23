import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:poketask/pages/battles_page.dart';
import 'package:poketask/pages/calendar.dart';
import 'package:poketask/pages/open.dart';
import 'package:poketask/pages/pokedex.dart';
import 'package:poketask/pages/taskspage.dart';
import 'package:poketask/pages/threads_page.dart';
import 'package:poketask/pages/folders_page.dart';
import 'pages/homepage.dart';
import 'pages/pokebattle_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'services/music_service.dart';
import 'pages/login_form.dart';
import 'pages/signup_form.dart';
import 'pages/fav_pokemon.dart';
import 'pages/starter_select.dart';


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
    // Start menu music globally
    MusicService().playMusic('music/menu_music.mp3');
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
      initialRoute: 'open',
      onGenerateRoute: (settings) {
        if (settings.name == 'home') {
          final args = settings.arguments as Map<String, dynamic>?;
          final trainerId = args != null ? args['trainer_id'] as String? : null;
          return MaterialPageRoute(
            builder: (context) => MyHomePage(
              title: 'PokeTask Home Page',
              trainerId: trainerId ?? '',
            ),
          );
        }
        // fallback to default
        return null;
      },
      routes: {
        'open': (context) => OpenPage(),
        'calendar': (context) => CalendarPage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        'tasks': (context) => TasksPage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        '/threads': (context) => ThreadsPage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        '/folders': (context) => FoldersPage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        '/pokebattle': (context) => PokeBattlePage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        'pokedex': (context) => PokedexPage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        'battles': (context) => BattlesPage(trainerId: 'e9c30ce7-f62e-464d-ba22-39b936172b57'),
        '/login': (context) => LoginFormPage(),
        '/signup': (context) => SignupFormPage(),
        '/starter_select': (context) => StarterSelectPage(),
      }
    );
  }
}
