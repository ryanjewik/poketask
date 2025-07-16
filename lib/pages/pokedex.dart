import 'package:flutter/material.dart';
import '../services/my_scaffold.dart';
import '../models/pokemon.dart';
import '../models/trainer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class PokedexPage extends StatefulWidget {
  final String trainerId;
  const PokedexPage({super.key, required this.trainerId});



  @override
  State<PokedexPage> createState() => _PokedexPageState();
}


class _PokedexPageState extends State<PokedexPage> {
  List<Pokemon> pokemonList = [];
  Pokemon? selectedPokemon;
  bool isLoading = true;
  bool _didFetch = false;
  Map<String, String> abilityNames = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetch) {
      fetchPokemon(widget.trainerId);
      _didFetch = true;
    }
  }

  Future<void> fetchPokemon(String trainerId) async {
    final response = await Supabase.instance.client
        .from('pokemon_table')
        .select()
        .eq('trainer_id', trainerId);
    final List<Pokemon> fetched = (response as List)
        .map((json) => Pokemon.fromJson(json))
        .toList();
    // Collect all unique ability IDs, trimmed and non-empty
    final abilityIds = <String>{};
    for (final poke in fetched) {
      if (poke.ability1.trim().isNotEmpty) abilityIds.add(poke.ability1.trim());
      if (poke.ability2.trim().isNotEmpty) abilityIds.add(poke.ability2.trim());
      if (poke.ability3.trim().isNotEmpty && poke.ability3.trim() != 'null') abilityIds.add(poke.ability3.trim());
      if (poke.ability4.trim().isNotEmpty && poke.ability4.trim() != 'null') abilityIds.add(poke.ability4.trim());
    }

    // Fetch ability names from abilities_table
    Map<String, String> abilityMap = {};
    if (abilityIds.isNotEmpty) {
      final abilitiesResponse = await Supabase.instance.client
          .from('abilities_table')
          .select('ability_id, ability_name')
          .inFilter('ability_id', abilityIds.toList());
      for (final ab in abilitiesResponse as List) {
        abilityMap[ab['ability_id']] = ab['ability_name'] ?? ab['ability_id'];
      }
    }
    if (!mounted) return;
    setState(() {
      pokemonList = fetched;
      selectedPokemon = fetched.isNotEmpty ? fetched[0] : null;
      isLoading = false;
      abilityNames = abilityMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (pokemonList.isEmpty) {
      return const Center(child: Text('No Pokémon found.'));
    }
    final Pokemon displayPokemon = selectedPokemon ?? pokemonList[0];
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset('assets/background/mobile_grid_background_2.jpg',
                fit: BoxFit.fill,
              ),
            ),
          ),
          MyScaffold(
            selectedIndex: 3,
            trainerId: displayPokemon.trainerId,
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    flex: 2, // Less space for image/stats
                    child: Row(
                      children: [
                        Expanded(//pokemon
                          flex: 1,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Shadow image
                              Positioned(
                                left: -6,
                                top: 5.0,
                                child: Image.asset(
                                  "assets/sprites/${displayPokemon.pokemonName.toLowerCase()}.png",
                                  color: Colors.black.withAlpha(250),
                                  colorBlendMode: BlendMode.srcATop,
                                  width: 200, // adjust as needed
                                  height: 200, // adjust as needed
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                              // Main image
                              Image.asset(
                                "assets/sprites/${displayPokemon.pokemonName.toLowerCase()}.png",
                                width: 200, // match shadow size
                                height: 200,
                                filterQuality: FilterQuality.high,
                              ),
                            ],
                          )
                        ),
                        Expanded(//pokemon stats
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0x9ECACACA), // Light grey background
                                border: Border.all(color: Colors.redAccent, width: 3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayPokemon.nickname,
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2),
                                  Text('Level: ${displayPokemon.level}', style: TextStyle(fontSize: 13)),
                                  SizedBox(height: 2),
                                  Text('Type: ${displayPokemon.type}', style: TextStyle(fontSize: 13)),
                                  SizedBox(height: 2),
                                  Text('Attack: ${displayPokemon.attack}', style: TextStyle(fontSize: 13)),
                                  SizedBox(height: 2),
                                  Text('Health: ${displayPokemon.health}', style: TextStyle(fontSize: 13)),
                                  SizedBox(height: 2),
                                  if (displayPokemon.ability1.trim().isNotEmpty && displayPokemon.ability1.trim() != 'null')
                                    Text('Ability 1: ${abilityNames[displayPokemon.ability1.trim()] ?? displayPokemon.ability1}', style: TextStyle(fontSize: 13)),
                                  if (displayPokemon.ability2.trim().isNotEmpty && displayPokemon.ability2.trim() != 'null')
                                    Text('Ability 2: ${abilityNames[displayPokemon.ability2.trim()] ?? displayPokemon.ability2}', style: TextStyle(fontSize: 13)),
                                  if (displayPokemon.ability3.trim().isNotEmpty && displayPokemon.ability3.trim() != 'null')
                                    Text('Ability 3: ${abilityNames[displayPokemon.ability3.trim()] ?? displayPokemon.ability3}', style: TextStyle(fontSize: 13)),
                                  if (displayPokemon.ability4.trim().isNotEmpty && displayPokemon.ability4.trim() != 'null')
                                    Text('Ability 4: ${abilityNames[displayPokemon.ability4.trim()] ?? displayPokemon.ability4}', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ))
                      ]
                    )
                  ),
                  // Grid of Pokémon at the bottom
                  Expanded(
                    flex: 3, // More space for grid
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1,
                      ),
                      itemCount: pokemonList.length,
                      itemBuilder: (context, index) {
                        final poke = pokemonList[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPokemon = poke;
                            });
                          },
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/sprites/${poke.pokemonName.toLowerCase()}.png",
                                  width: 48,
                                  height: 48,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.catching_pokemon),
                                ),
                                Text(poke.nickname.isNotEmpty ? poke.nickname : poke.pokemonName),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
