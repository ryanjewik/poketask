import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginFormPage extends StatefulWidget {
  const LoginFormPage({Key? key}) : super(key: key);

  @override
  State<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends State<LoginFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background/mobile_grid_background_2.jpg',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.85),
              colorBlendMode: BlendMode.lighten,
            ),
          ),
          Center(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.redAccent, width: 4),
              ),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.catching_pokemon, size: 64, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontFamily: 'PressStart2P',
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Email'),
                        onChanged: (value) => _email = value,
                        validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        onChanged: (value) => _password = value,
                        validator: (value) => value == null || value.isEmpty ? 'Enter your password' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Fredoka',
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final client = Supabase.instance.client;
                              try {
                                final user = await client.auth.signInWithPassword(
                                  email: _email,
                                  password: _password,
                                );
                                // Login successful
                                if (user.user != null) {
                                  if (!mounted) return;
                                  print('✅ Welcome \\${user.user!.email}');
                                  final userId = client.auth.currentUser?.id;
                                  if (userId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Login failed: No user ID found. Please try again.')),
                                    );
                                    return;
                                  }
                                  // Check if trainer record exists
                                  final trainer = await client
                                      .from('trainer_table')
                                      .select('trainer_id')
                                      .eq('trainer_id', userId)
                                      .maybeSingle();
                                  if (trainer == null) {
                                    // Prompt for username and gender
                                    final result = await showDialog<Map<String, String>>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        String username = '';
                                        String gender = 'Male';
                                        return AlertDialog(
                                          title: const Text('Complete Your Profile'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFormField(
                                                decoration: const InputDecoration(labelText: 'Username'),
                                                onChanged: (value) => username = value,
                                              ),
                                              DropdownButtonFormField<String>(
                                                value: gender,
                                                decoration: const InputDecoration(labelText: 'Gender'),
                                                items: const [
                                                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                                                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                                                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                                                ],
                                                onChanged: (value) {
                                                  if (value != null) gender = value;
                                                },
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                if (username.isNotEmpty) {
                                                  Navigator.of(context).pop({'username': username, 'gender': gender});
                                                }
                                              },
                                              child: const Text('Continue'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (result != null && result['username'] != null) {
                                      await client.from('trainer_table').insert({
                                        'trainer_id': userId,
                                        'username': result['username'],
                                        'sex': result['gender'],
                                        'created_at': DateTime.now().toIso8601String(),
                                        'wins': 0,
                                        'losses': 0,
                                        'completed_tasks': 0,
                                        'level': 1,
                                        'experience_points': 0,
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Profile created!')),
                                      );
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/starter_select',
                                        arguments: {'trainer_id': userId},
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Login successful!')),
                                    );
                                    Navigator.pushReplacementNamed(
                                      context,
                                      'home',
                                      arguments: {'trainer_id': userId},
                                    );
                                  }
                                }
                              } on AuthException catch (e) {
                                if (!mounted) return;
                                print('❌ Login error: \\${e.message}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Invalid email or password. Please try again.')),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                print('❌ Login error: \\${e.toString()}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('An unexpected error occurred. Please try again.')),
                                );
                              }
                            }
                          },
                          child: const Text('Login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
