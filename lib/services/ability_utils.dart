import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


/// Fetches a random ability from the abilities_table, excluding the given ability IDs.
Future<Map<String, dynamic>?> fetchRandomAbilityExcluding(List<String> excludeAbilityIds) async {
  final supabase = Supabase.instance.client;
  // Exclude abilities already owned
  if (excludeAbilityIds.isEmpty) {
    final abilities = await supabase
        .from('abilities_table')
        .select();
    if (abilities == null || abilities.isEmpty) return null;
    abilities.shuffle();
    return abilities.first;
  } else {
    // Join UUIDs without extra quotes for Postgres
    final excludeList = excludeAbilityIds.map((id) => "'$id'").join(",");
    final abilities = await supabase
        .from('abilities_table')
        .select()
        .not('ability_id', 'in', '($excludeList)');
    if (abilities == null || abilities.isEmpty) return null;
    abilities.shuffle();
    return abilities.first;
  }
}

/// Offers a dialog to the user to swap a new ability with an existing one or ignore it.
Future<void> offerAbilityDialog({
  required BuildContext context,
  required Map<String, dynamic> ability,
  required String pokeId,
  required List<String> currentAbilityIds,
}) async {
  final supabase = Supabase.instance.client;
  String abilityName = ability['ability_name'] ?? 'Unknown';
  String abilityType = ability['type'] ?? '';
  String abilityId = ability['ability_id'].toString();
  // Fetch current ability details for better button labels
  List<Map<String, dynamic>> currentAbilities = [];
  if (currentAbilityIds.isNotEmpty) {
    final abilitiesRes = await supabase
      .from('abilities_table')
      .select()
      .filter('ability_id', 'in', '(${currentAbilityIds.join(',')})');
    if (abilitiesRes != null && abilitiesRes is List) {
      // Sort abilities to match the order of currentAbilityIds
      final abilityMap = {for (var ab in abilitiesRes) ab['ability_id'].toString(): ab};
      currentAbilities = currentAbilityIds.map((id) => abilityMap[id] ?? {'ability_name': 'Unknown', 'type': ''}).toList();
    }
  }
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('New Ability Unlocked!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Pokémon can learn a new ability:'),
            Text('$abilityName ($abilityType)'),
            const SizedBox(height: 16),
            Text('Do you want to replace an existing ability?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ignore'),
          ),
          for (int i = 0; i < currentAbilityIds.length; i++)
            TextButton(
              onPressed: () async {
                await supabase.from('pokemon_table').update({
                  'ability${i + 1}': abilityId,
                }).eq('pokemon_id', pokeId);
                Navigator.of(context).pop();
              },
              child: Text(
                currentAbilities.isNotEmpty
                  ? '${currentAbilities[i]['ability_name']} (${currentAbilities[i]['type']})'
                  : 'Ability ${i + 1}'
              ),
            ),
        ],
      );
    },
  );
}

/// Fetches a random Pokémon (name and type) from the CSV file.
Future<Map<String, String>> fetchRandomPokemonFromCsv() async {
  final csvString = await rootBundle.loadString('assets/pokemon_names_list.csv');
  final lines = LineSplitter.split(csvString).toList();
  if (lines.length <= 1) throw Exception('No Pokémon data found');
  final rng = Random();
  final idx = rng.nextInt(lines.length - 1) + 1; // skip header
  final row = lines[idx].split(',');
  return {'pokemon_name': row[0], 'type': row[1]};
}

/// Adds a new Pokémon to the trainer's team in the database and returns the new pokemon_id.
Future<String?> addRandomPokemonToTrainer(String trainerId, {BuildContext? context}) async {
  final supabase = Supabase.instance.client;
  final pokemon = await fetchRandomPokemonFromCsv();

  // --- Ability selection logic ---
  final abilities = await supabase
      .from('abilities_table')
      .select();
  if (abilities == null || abilities.isEmpty) {
    print('No abilities found in abilities_table');
    return null;
  }
  final typeAbilities = abilities.where((a) => a['type'] == pokemon['type']).toList();
  final otherAbilities = abilities.where((a) => a['type'] != pokemon['type']).toList();
  final rng = Random();
  List chosenAbilities = [];
  final usedAbilityIds = <dynamic>{};

  // Ensure at least two unique type-matching abilities if possible
  typeAbilities.shuffle(rng);
  for (var ab in typeAbilities) {
    if (chosenAbilities.length < 2 && !usedAbilityIds.contains(ab['ability_id'])) {
      chosenAbilities.add(ab);
      usedAbilityIds.add(ab['ability_id']);
    }
  }
  // If not enough type-matching, fill with other types, still unique
  final allAbilities = [...typeAbilities, ...otherAbilities];
  allAbilities.shuffle(rng);
  for (var ab in allAbilities) {
    if (chosenAbilities.length >= 4) break;
    if (!usedAbilityIds.contains(ab['ability_id'])) {
      chosenAbilities.add(ab);
      usedAbilityIds.add(ab['ability_id']);
    }
  }
  // Defensive: if not enough, fill with empty maps
  while (chosenAbilities.length < 4) {
    chosenAbilities.add({});
  }
  // Assign random health (25-40) and attack (10-30)
  final health = 25 + rng.nextInt(16); // 25 to 40 inclusive
  final attack = 10 + rng.nextInt(21); // 10 to 30 inclusive
  // Insert new Pokémon (do NOT assign to any slot, just set trainer_id)
  final insertRes = await supabase
      .from('pokemon_table')
      .insert({
        'pokemon_name': pokemon['pokemon_name'],
        'type': pokemon['type'],
        'level': 1,
        'experience_points': 0,
        'nickname': pokemon['pokemon_name'],
        'trainer_id': trainerId,
        'ability1': chosenAbilities[0]['ability_id'],
        'ability2': chosenAbilities[1]['ability_id'],
        'ability3': chosenAbilities[2]['ability_id'],
        'ability4': chosenAbilities[3]['ability_id'],
        'health': health,
        'attack': attack,
        // Add other default fields as needed
      })
      .select()
      .maybeSingle();
  if (insertRes == null) {
    print('Failed to insert new Pokémon for trainer $trainerId');
    return null;
  }
  print('Added new Pokémon ${pokemon['pokemon_name']} for trainer $trainerId');
  return insertRes['pokemon_id']?.toString();
}

/// Shows a dialog to notify the user of a new Pokémon.
Future<void> showNewPokemonDialog(BuildContext context, String pokemonName, String type) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('New Pokémon!'),
      content: Text('You received a new Pokémon: $pokemonName ($type)!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
