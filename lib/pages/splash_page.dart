import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    final userId = client.auth.currentUser?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (session != null) {
        Navigator.pushReplacementNamed(context, 'home',
          arguments: {'trainer_id': userId},);
      } else {
        Navigator.pushReplacementNamed(context, 'open');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
