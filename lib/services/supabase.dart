import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Optional: Run a simple query to test connection
  final supabase = Supabase.instance.client;

  try {
    // Replace 'health_check' with an actual table in your DB
    final response = await supabase.from('health_check').select().limit(1);
    debugPrint('✅ Supabase connected: ${response}');
  } catch (e) {
    debugPrint('❌ Supabase connection failed: $e');
  }


}
