import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fetches a random ability from the abilities_table, excluding the given ability IDs.
Future<Map<String, dynamic>?> fetchRandomAbilityExcluding(List<String> excludeAbilityIds) async {
  final supabase = Supabase.instance.client;
  // Join UUIDs without extra quotes for Postgres
  final excludeList = excludeAbilityIds.join(",");
  final abilities = await supabase
      .from('abilities_table')
      .select()
      .not('ability_id', 'in', '($excludeList)');
  if (abilities == null || abilities.isEmpty) return null;
  abilities.shuffle();
  return abilities.first;
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
