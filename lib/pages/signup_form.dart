import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class SignupFormPage extends StatefulWidget {
  const SignupFormPage({Key? key}) : super(key: key);

  @override
  State<SignupFormPage> createState() => _SignupFormPageState();
}

class _SignupFormPageState extends State<SignupFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _username = '';
  String _gender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
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
                        'Sign Up',
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
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        onChanged: (value) => _confirmPassword = value,
                        validator: (value) => value != _password ? 'Passwords do not match' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Username'),
                        onChanged: (value) => _username = value,
                        validator: (value) => value == null || value.isEmpty ? 'Enter a username' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(labelText: 'Gender'),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _gender = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
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
                              // Check if email or username exists
                              final emailRes = await client
                                  .from('user_authentication_table')
                                  .select('trainer_id')
                                  .eq('email', _email)
                                  .maybeSingle();
                              final usernameRes = await client
                                  .from('trainer_table')
                                  .select('trainer_id')
                                  .eq('username', _username)
                                  .maybeSingle();
                              if (emailRes != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Email is already taken.')),
                                );
                                return;
                              }
                              if (usernameRes != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Username is already taken.')),
                                );
                                return;
                              }
                              // Hash the password
                              final hashedPassword = sha256.convert(utf8.encode(_password)).toString();
                              // Generate a UUID for trainer_id
                              final trainerId = const Uuid().v4();
                              // Insert into user_authentication_table
                              final authInsert = await client
                                  .from('user_authentication_table')
                                  .insert({
                                    'trainer_id': trainerId,
                                    'email': _email,
                                    'password': hashedPassword,
                                    'created_at': DateTime.now().toIso8601String(),
                                    'username': _username,
                                  })
                                  .select('trainer_id')
                                  .maybeSingle();
                              if (authInsert == null || authInsert['trainer_id'] == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Signup failed. Please try again.')),
                                );
                                return;
                              }
                              // Insert into trainer_table
                              final trainerInsert = await client
                                  .from('trainer_table')
                                  .insert({
                                    'trainer_id': trainerId,
                                    'username': _username,
                                    'sex': _gender,
                                    'created_at': DateTime.now().toIso8601String(),
                                    'wins': 0,
                                    'losses': 0,
                                    'completed_tasks': 0,
                                    'level': 1,
                                    'experience_points': 0,
                                  })
                                  .select('trainer_id')
                                  .maybeSingle();
                              if (trainerInsert == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Trainer creation failed.')),
                                );
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Signup successful!')),
                              );
                              Navigator.pushReplacementNamed(context, '/starter_select', arguments: {'trainer_id': trainerId});
                            }
                          },
                          child: const Text('Sign Up'),
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
