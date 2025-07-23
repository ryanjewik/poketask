import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StarterSelectPage extends StatefulWidget {
  const StarterSelectPage({Key? key}) : super(key: key);

  @override
  State<StarterSelectPage> createState() => _StarterSelectPageState();
}

class _StarterSelectPageState extends State<StarterSelectPage> {
  String? _selectedStarter;
  bool _isLoading = false;

  final List<Map<String, String>> starters = [
    {
      'name': 'Bulbasaur',
      'sprite': 'assets/sprites/bulbasaur.png',
      'species': 'Bulbasaur',
      'type': 'Grass/Poison',
    },
    {
      'name': 'Charmander',
      'sprite': 'assets/sprites/charmander.png',
      'species': 'Charmander',
      'type': 'Fire',
    },
    {
      'name': 'Squirtle',
      'sprite': 'assets/sprites/squirtle.png',
      'species': 'Squirtle',
      'type': 'Water',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final trainerId = args != null ? args['trainer_id'] as String? : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Starter Pokémon'),
        automaticallyImplyLeading: false,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.catching_pokemon, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    const Text(
                      'Select your starter Pokémon!',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: starters.map((starter) {
                        final isSelected = _selectedStarter == starter['name'];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStarter = starter['name'];
                                });
                              },
                              child: SizedBox(
                                height: 120,
                                child: Card(
                                  color: isSelected ? Colors.redAccent.withOpacity(0.7) : Colors.white,
                                  elevation: isSelected ? 12 : 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: isSelected ? Colors.redAccent : Colors.grey.shade300,
                                      width: 3,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          starter['sprite']!,
                                          width: 56,
                                          height: 56,
                                        ),
                                        const SizedBox(height: 8),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            starter['name']!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.white : Colors.black,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
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
                        onPressed: _isLoading || _selectedStarter == null || trainerId == null
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                final client = Supabase.instance.client;
                                final uuid = const Uuid().v4();
                                final starter = starters.firstWhere((s) => s['name'] == _selectedStarter);
                                final rng = Random();
                                final attack = 10 + rng.nextInt(26); // 10-35
                                final health = 30 + rng.nextInt(31); // 30-60
                                // Get types (handle dual types)
                                final types = starter['type']!.split('/').map((t) => t.trim()).toList();
                                // Query for abilities matching type
                                final typeAbilitiesRes = await client
                                    .from('abilities_table')
                                    .select('ability_id, ability_name, type')
                                    .filter('type', 'in', '(${types.map((t) => '"$t"').join(',')})')
                                    .limit(10);
                                final typeAbilities = (typeAbilitiesRes as List)
                                    .map((a) => {'id': a['ability_id'] as String, 'name': a['ability_name'] as String})
                                    .toList();
                                // Query for all other abilities
                                final allAbilitiesRes = await client
                                    .from('abilities_table')
                                    .select('ability_id, ability_name, type');
                                final allAbilities = (allAbilitiesRes as List)
                                    .map((a) => {'id': a['ability_id'] as String, 'name': a['ability_name'] as String})
                                    .toList();
                                // Pick at least 2 type-matching abilities
                                typeAbilities.shuffle(rng);
                                final selectedAbilities = <Map<String, String>>[];
                                selectedAbilities.addAll(typeAbilities.take(2));
                                // Fill up to 4 with random unique abilities (by id)
                                final selectedIds = selectedAbilities.map((a) => a['id']).toSet();
                                final remainingAbilities = allAbilities.where((a) => !selectedIds.contains(a['id'])).toList()..shuffle(rng);
                                for (var ab in remainingAbilities) {
                                  if (selectedAbilities.length >= 4) break;
                                  selectedAbilities.add(ab);
                                  selectedIds.add(ab['id']);
                                }
                                // If not enough, fill with more randoms
                                if (selectedAbilities.length < 4) {
                                  final more = allAbilities.where((a) => !selectedIds.contains(a['id'])).toList()..shuffle(rng);
                                  for (var ab in more) {
                                    if (selectedAbilities.length >= 4) break;
                                    selectedAbilities.add(ab);
                                    selectedIds.add(ab['id']);
                                  }
                                }
                                final abilities = selectedAbilities.toList()..shuffle(rng);
                                // Insert into pokemon_table using ability UUIDs
                                final pokemonInsert = await client
                                    .from('pokemon_table')
                                    .insert({
                                      'pokemon_id': uuid,
                                      'pokemon_name': starter['species'],
                                      'nickname': starter['name'],
                                      'level': 1,
                                      'experience_points': 0,
                                      'type': starter['type'],
                                      'attack': attack,
                                      'health': health,
                                      'ability1': abilities.isNotEmpty ? abilities[0]['id'] : null,
                                      'ability2': abilities.length > 1 ? abilities[1]['id'] : null,
                                      'ability3': abilities.length > 2 ? abilities[2]['id'] : null,
                                      'ability4': abilities.length > 3 ? abilities[3]['id'] : null,
                                      'trainer_id': trainerId,
                                      'date_caught': DateTime.now().toIso8601String(),
                                    })
                                    .select('pokemon_id')
                                    .maybeSingle();
                                if (pokemonInsert == null || pokemonInsert['pokemon_id'] == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to create starter Pokémon.')),
                                  );
                                  setState(() => _isLoading = false);
                                  return;
                                }
                                final pokemonId = pokemonInsert['pokemon_id'];
                                // Update trainer_table
                                final trainerUpdate = await client
                                    .from('trainer_table')
                                    .update({
                                      'pokemon_slot_1': pokemonId,
                                      'favorite_pokemon': pokemonId,
                                    })
                                    .eq('trainer_id', trainerId)
                                    .select('trainer_id')
                                    .maybeSingle();
                                if (trainerUpdate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to update trainer.')),
                                  );
                                  setState(() => _isLoading = false);
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${starter['species']} selected as your starter!')),
                                );
                                // Route to homepage with trainer_id after successful starter selection
                                Navigator.pushReplacementNamed(
                                  context,
                                  'home',
                                  arguments: {'trainer_id': trainerId},
                                );
                              },
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Confirm Selection'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
