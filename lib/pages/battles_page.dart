import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pokemon.dart';
import '../models/trainer.dart';
import '../services/my_scaffold.dart';
import '../services/music_service.dart';


class BattlesPage extends StatefulWidget {
  const BattlesPage({super.key, required this.trainerId});
  final String trainerId;

  @override
  State<BattlesPage> createState() => _BattlesPageState();
}

class _BattlesPageState extends State<BattlesPage> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _slideAnimations;
  bool showByTasks = true;

  Trainer? trainer;
  bool isLoading = true;
  String? errorMessage;
  List<Pokemon> trainerPokemons = [];
  List<Trainer> trainerList = [];

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(5, (i) => AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200 + i * 60),
    ));
    _slideAnimations = List.generate(5, (i) => Tween<Offset>(
      begin: Offset(-1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllers[i],
      curve: Curves.easeOutBack,
    )));
    // Staggered animation
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 80 * i), () {
        if (mounted) _controllers[i].forward();
      });
    }
    fetchTrainerAndPokemon();
    fetchAllTrainers();
  }

  Future<void> fetchTrainerAndPokemon() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final supabase = Supabase.instance.client;
      final trainerResponse = await supabase
        .from('trainer_table')
        .select()
        .eq('trainer_id', widget.trainerId)
        .maybeSingle(); // Use maybeSingle to avoid exception
      if (trainerResponse == null) {
        setState(() {
          errorMessage = 'Trainer not found.';
          isLoading = false;
        });
        return;
      }
      trainer = Trainer.fromJson(trainerResponse);
      final slotIds = [
        trainer!.pokemonSlot1,
        trainer!.pokemonSlot2,
        trainer!.pokemonSlot3,
        trainer!.pokemonSlot4,
        trainer!.pokemonSlot5,
        trainer!.pokemonSlot6,
      ].where((id) => id != null && id.isNotEmpty).toList();
      if (slotIds.isNotEmpty) {
        final formattedIds = slotIds.join(',');
        final pokemonResponse = await supabase
          .from('pokemon_table')
          .select()
          .filter('pokemon_id', 'in', '($formattedIds)'); // Correct usage for Supabase
        trainerPokemons = (pokemonResponse as List).map((json) => Pokemon.fromJson(json)).toList();
      } else {
        trainerPokemons = [];
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error fetching trainer or Pokémon: ' + e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchAllTrainers() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('trainer_table')
        .select();
    trainerList = (response as List).map((json) => Trainer.fromJson(json)).toList();
  }

  @override
  void dispose() {
    MusicService().playMusic('music/menu_music.mp3');
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)));
    }
    // Use the fetched trainer
    final t = trainer;
    // Remove old slotIds and trainerPokemons logic in build
    // Get top 5 trainers by experiencePoints or wins
    List<Trainer> sortedTrainers = List<Trainer>.from(trainerList);
    if (showByTasks) {
      sortedTrainers.sort((a, b) => b.experiencePoints.compareTo(a.experiencePoints));
    } else {
      sortedTrainers.sort((a, b) => b.wins.compareTo(a.wins));
    }
    final top5 = sortedTrainers.take(5).toList();
    return Container(
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/background/gym-background.jpg',
                fit: BoxFit.fill,
              ),
            ),
          ),
          MyScaffold(
            selectedIndex: 4,
            trainerId: t?.trainerId ?? '1',
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: t == null
                      ? Center(child: Text('No trainer found', style: TextStyle(color: Colors.white)))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t.username,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6,
                                    color: Colors.black.withOpacity(0.7),
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Level: ${t.level}   XP: ${t.experiencePoints}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Wins: ${t.wins}   Losses: ${t.losses}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.lightGreenAccent,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Wrap(
                              spacing: 12,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                    child: GridView.count(
                                      crossAxisCount: 2, // 2 columns
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      childAspectRatio: 2.5, // Decrease aspect ratio for taller tiles
                                      mainAxisSpacing: 8, // Add vertical gap between tiles
                                      crossAxisSpacing: 8, // Add horizontal gap between tiles
                                      children: List.generate(6, (i) {
                                        final slotPokemons = [
                                          t.pokemonSlot1,
                                          t.pokemonSlot2,
                                          t.pokemonSlot3,
                                          t.pokemonSlot4,
                                          t.pokemonSlot5,
                                          t.pokemonSlot6,
                                        ];
                                        final Pokemon? poke = trainerPokemons.where((p) => p.pokemonId == slotPokemons[i]).isNotEmpty ? trainerPokemons.firstWhere((p) => p.pokemonId == slotPokemons[i]) : null;
                                        if (poke == null) {
                                          // Empty tile for null slot
                                          return GestureDetector(
                                            onTap: () async {
                                              // Fetch all Pokémon for this trainer
                                              final supabase = Supabase.instance.client;
                                              final allPokemonResponse = await supabase
                                                .from('pokemon_table')
                                                .select()
                                                .eq('trainer_id', widget.trainerId);
                                              final allPokemon = (allPokemonResponse as List).map((p) => Pokemon.fromJson(p)).toList();
                                              // Exclude Pokémon already in slots
                                              final slotIds = [
                                                t.pokemonSlot1,
                                                t.pokemonSlot2,
                                                t.pokemonSlot3,
                                                t.pokemonSlot4,
                                                t.pokemonSlot5,
                                                t.pokemonSlot6,
                                              ];
                                              final eligiblePokemon = allPokemon.where((p) => !slotIds.contains(p.pokemonId)).toList();
                                              if (eligiblePokemon.isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('No eligible Pokémon to select.')),
                                                );
                                                return;
                                              }
                                              final selected = await showDialog<Pokemon>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  backgroundColor: Colors.grey[900],
                                                  title: Text('Select a Pokémon', style: TextStyle(color: Colors.amber)),
                                                  content: SizedBox(
                                                    width: 300,
                                                    height: 300,
                                                    child: ListView.builder(
                                                      itemCount: eligiblePokemon.length,
                                                      itemBuilder: (context, idx) {
                                                        final poke = eligiblePokemon[idx];
                                                        return ListTile(
                                                          leading: Image.asset(
                                                            'assets/sprites/${poke.pokemonName.toLowerCase()}.png',
                                                            width: 48,
                                                            height: 48,
                                                          ),
                                                          title: Text(poke.nickname, style: TextStyle(color: Colors.white)),
                                                          subtitle: Text('Lv. ${poke.level}'),
                                                          onTap: () {
                                                            Navigator.of(context).pop(poke);
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                              if (selected != null) {
                                                // Update the slot in the database
                                                String slotField = '';
                                                switch (i) {
                                                  case 0:
                                                    slotField = 'pokemon_slot_1';
                                                    break;
                                                  case 1:
                                                    slotField = 'pokemon_slot_2';
                                                    break;
                                                  case 2:
                                                    slotField = 'pokemon_slot_3';
                                                    break;
                                                  case 3:
                                                    slotField = 'pokemon_slot_4';
                                                    break;
                                                  case 4:
                                                    slotField = 'pokemon_slot_5';
                                                    break;
                                                  case 5:
                                                    slotField = 'pokemon_slot_6';
                                                    break;
                                                }
                                                await supabase
                                                  .from('trainer_table')
                                                  .update({slotField: selected.pokemonId})
                                                  .eq('trainer_id', widget.trainerId);
                                                // Update local state and refresh grid
                                                setState(() {
                                                  switch (i) {
                                                    case 0:
                                                      t.pokemonSlot1 = selected.pokemonId;
                                                      break;
                                                    case 1:
                                                      t.pokemonSlot2 = selected.pokemonId;
                                                      break;
                                                    case 2:
                                                      t.pokemonSlot3 = selected.pokemonId;
                                                      break;
                                                    case 3:
                                                      t.pokemonSlot4 = selected.pokemonId;
                                                      break;
                                                    case 4:
                                                      t.pokemonSlot5 = selected.pokemonId;
                                                      break;
                                                    case 5:
                                                      t.pokemonSlot6 = selected.pokemonId;
                                                      break;
                                                  }
                                                });
                                                await fetchTrainerAndPokemon();
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[800],
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.amber, width: 1.5),
                                              ),
                                              height: 60,
                                              child: Center(
                                                child: Icon(Icons.help_outline, color: Colors.grey[600], size: 32),
                                              ),
                                            ),
                                          );
                                        }
                                        return GestureDetector(
                                          onTap: () async {
                                            final slotIds = [
                                              t.pokemonSlot1,
                                              t.pokemonSlot2,
                                              t.pokemonSlot3,
                                              t.pokemonSlot4,
                                              t.pokemonSlot5,
                                              t.pokemonSlot6,
                                            ];
                                            int slotIndex = slotIds.indexOf(poke.pokemonId);
                                            // Fetch ability names from abilities_table
                                            final supabase = Supabase.instance.client;
                                            final abilityIds = [poke.ability1, poke.ability2, poke.ability3, poke.ability4];
                                            List<String> abilityNames = [];
                                            if (abilityIds.isNotEmpty) {
                                              final formattedIds = abilityIds.where((id) => id != null && id.toString().isNotEmpty).join(',');
                                              final abilitiesResponse = await supabase
                                                .from('abilities_table')
                                                .select()
                                                .filter('ability_id', 'in', '($formattedIds)');
                                              abilityNames = (abilitiesResponse as List).map((a) => a['ability_name']?.toString() ?? '').toList();
                                            }
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: Colors.grey[900],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(24),
                                                  side: BorderSide(color: Colors.amber, width: 3),
                                                ),
                                                title: Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/sprites/${poke.pokemonName.toLowerCase()}.png',
                                                      width: 72,
                                                      height: 72,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        poke.nickname,
                                                        style: TextStyle(fontSize: 28, color: Colors.amber, fontWeight: FontWeight.bold),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        softWrap: false,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Type: ${poke.type}', style: TextStyle(color: Colors.white, fontSize: 20)),
                                                    Text('Level: ${poke.level}', style: TextStyle(color: Colors.white, fontSize: 20)),
                                                    // Experience Progress Bar
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('XP: ${poke.experiencePoints} / ${((100 * poke.level * 1.1).toInt())}', style: TextStyle(color: Colors.lightGreenAccent, fontSize: 16)),
                                                          SizedBox(height: 4),
                                                          LinearProgressIndicator(
                                                            value: poke.experiencePoints / (100 * poke.level * 1.1),
                                                            minHeight: 8,
                                                            backgroundColor: Colors.grey[800],
                                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text('Attack: ${poke.attack}', style: TextStyle(color: Colors.white, fontSize: 20)),
                                                    Text('Health: ${poke.health}', style: TextStyle(color: Colors.white, fontSize: 20)),
                                                    SizedBox(height: 8),
                                                    Text('Moves:', style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
                                                    for (int i = 0; i < abilityNames.length; i++)
                                                      Text('${i + 1}. ${abilityNames[i]}', style: TextStyle(color: Colors.white, fontSize: 20)),
                                                  ],
                                                ),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.deepOrange,
                                                          foregroundColor: Colors.white,
                                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                        ),
                                                        onPressed: () async {
                                                          Navigator.of(context).pop();
                                                          // Fetch all Pokémon for this trainer
                                                          final allPokemonResponse = await supabase
                                                            .from('pokemon_table')
                                                            .select()
                                                            .eq('trainer_id', widget.trainerId);
                                                          final allPokemon = (allPokemonResponse as List).map((p) => Pokemon.fromJson(p)).toList();
                                                          // Exclude Pokémon already in slots
                                                          final slotIds = [
                                                            t.pokemonSlot1,
                                                            t.pokemonSlot2,
                                                            t.pokemonSlot3,
                                                            t.pokemonSlot4,
                                                            t.pokemonSlot5,
                                                            t.pokemonSlot6,
                                                          ];
                                                          final eligiblePokemon = allPokemon.where((p) => !slotIds.contains(p.pokemonId)).toList();
                                                          if (eligiblePokemon.isEmpty) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('No eligible Pokémon to select.')),
                                                            );
                                                            return;
                                                          }
                                                          final selected = await showDialog<Pokemon>(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              backgroundColor: Colors.grey[900],
                                                              title: Text('Select a Pokémon', style: TextStyle(color: Colors.amber)),
                                                              content: SizedBox(
                                                                width: 300,
                                                                height: 300,
                                                                child: ListView.builder(
                                                                  itemCount: eligiblePokemon.length,
                                                                  itemBuilder: (context, idx) {
                                                                    final poke = eligiblePokemon[idx];
                                                                    return ListTile(
                                                                      leading: Image.asset(
                                                                        'assets/sprites/${poke.pokemonName.toLowerCase()}.png',
                                                                        width: 48,
                                                                        height: 48,
                                                                      ),
                                                                      title: Text(poke.nickname, style: TextStyle(color: Colors.white)),
                                                                      subtitle: Text('Lv. ${poke.level}'),
                                                                      onTap: () {
                                                                        Navigator.of(context).pop(poke);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                          if (selected != null) {
                                                            // Update the slot in the database
                                                            String slotField = '';
                                                            switch (slotIndex) {
                                                              case 0:
                                                                slotField = 'pokemon_slot_1';
                                                                break;
                                                              case 1:
                                                                slotField = 'pokemon_slot_2';
                                                                break;
                                                              case 2:
                                                                slotField = 'pokemon_slot_3';
                                                                break;
                                                              case 3:
                                                                slotField = 'pokemon_slot_4';
                                                                break;
                                                              case 4:
                                                                slotField = 'pokemon_slot_5';
                                                                break;
                                                              case 5:
                                                                slotField = 'pokemon_slot_6';
                                                                break;
                                                            }
                                                            await supabase
                                                              .from('trainer_table')
                                                              .update({slotField: selected.pokemonId})
                                                              .eq('trainer_id', widget.trainerId);
                                                            // Update local state and refresh grid
                                                            setState(() {
                                                              switch (slotIndex) {
                                                                case 0:
                                                                  t.pokemonSlot1 = selected.pokemonId;
                                                                  break;
                                                                case 1:
                                                                  t.pokemonSlot2 = selected.pokemonId;
                                                                  break;
                                                                case 2:
                                                                  t.pokemonSlot3 = selected.pokemonId;
                                                                  break;
                                                                case 3:
                                                                  t.pokemonSlot4 = selected.pokemonId;
                                                                  break;
                                                                case 4:
                                                                  t.pokemonSlot5 = selected.pokemonId;
                                                                  break;
                                                                case 5:
                                                                  t.pokemonSlot6 = selected.pokemonId;
                                                                  break;
                                                              }
                                                            });
                                                            // Optionally, re-fetch Pokémon to update grid
                                                            await fetchTrainerAndPokemon();
                                                          }
                                                        },
                                                        child: Text('Change Pokémon'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: Text('Close', style: TextStyle(color: Colors.redAccent)),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[900]!.withOpacity(0.7), // More transparent background
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.amber, width: 1.5),
                                            ),
                                            height: 60,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 8),
                                                Image.asset(
                                                  'assets/sprites/${poke.pokemonName.toLowerCase()}.png',
                                                  width: 48,
                                                  height: 48,
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        poke.nickname,
                                                        style: TextStyle(
                                                          color: Colors.amber,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        'Lv. ${poke.level}',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5), // Increased padding above the button
                              child: SizedBox(
                                width: 220,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 6,
                                    textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.of(context).pushNamed(
                                      '/pokebattle',
                                      arguments: {'trainer_id': widget.trainerId},
                                    );
                                    if (result == 'refresh') {
                                      await fetchTrainerAndPokemon();
                                      setState(() {});
                                    }
                                  },
                                  child: Text('BATTLE', style: TextStyle(letterSpacing: 2)),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                Padding(
                  padding: EdgeInsets.zero, // no margin above/below
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: Colors.amber,
                    color: Colors.amber,
                    isSelected: [showByTasks, !showByTasks],
                    onPressed: (int idx) {
                      setState(() {
                        showByTasks = idx == 0;
                      });
                    },
                    constraints: BoxConstraints(minWidth: 100, minHeight: 20),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0), // minimal vertical padding
                        child: Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0), // minimal vertical padding
                        child: Text('Wins', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FutureBuilder<List<Trainer>>(
                    future: fetchTopTrainers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final top5 = snapshot.data ?? [];
                      return ListView.separated(
                        itemCount: top5.length,
                        separatorBuilder: (context, index) => SizedBox.shrink(),
                        itemBuilder: (context, index) {
                          final t = top5[index];
                          return SlideTransition(
                            position: _slideAnimations.length > index ? _slideAnimations[index] : AlwaysStoppedAnimation(Offset.zero),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                              decoration: BoxDecoration(
                                color: index == 0 ? Colors.amber.withAlpha(80) : Colors.black.withAlpha(40),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.amber, width: index == 0 ? 2 : 1),
                                boxShadow: [
                                  if (index == 0)
                                    BoxShadow(
                                      color: Colors.amber.withAlpha(60),
                                      blurRadius: 6,
                                      offset: Offset(0, 1),
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: index == 0 ? Colors.amber : Colors.grey[800],
                                    radius: 13,
                                    child: Text(
                                      '#${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: index == 0 ? Colors.deepOrange : Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            t.username,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
                                              fontSize: 17,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                                        SizedBox(width: 2),
                                        Text(
                                          showByTasks ? 'Tasks: ${t.completedTasks}' : 'Wins: ${t.wins}',
                                          style: TextStyle(
                                            color: Colors.lightGreenAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (index == 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 2.0),
                                      child: Icon(Icons.star, color: Colors.amber, size: 16),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Trainer>> fetchTopTrainers() async {
    try {
      final supabase = Supabase.instance.client;
      final trainersResponse = await supabase
        .from('trainer_table')
        .select()
        .order(showByTasks ? 'completed_tasks' : 'wins', ascending: false)
        .limit(5);
      return (trainersResponse as List).map((json) => Trainer.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
