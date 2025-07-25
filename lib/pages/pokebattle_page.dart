import 'package:flutter/material.dart';
import '../mcts/pokebattle_controller.dart';
import '../models/battle_game_state.dart';
import '../models/pokemon_mcts.dart';
import '../models/ability_mcts.dart';
import '../mcts/mcts_search.dart'; // For direct MCTS call
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/music_service.dart';
import '../services/xp_utils.dart';
import '../services/ability_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class PokeBattlePage extends StatefulWidget {
  final String trainerId;
  const PokeBattlePage({super.key, required this.trainerId});

  @override
  State<PokeBattlePage> createState() => _PokeBattlePageState();
}

class _PokeBattlePageState extends State<PokeBattlePage> {
  late PokeBattleController? controller;
  String? lastAiAction;
  bool playerJustAttacked = false;
  bool opponentJustAttacked = false;

  String narration = "";
  bool isAnimating = false;

  bool isMusicPlaying = true;

  String selectedArena = "";
  String selectedArenaText = "";
  final List<String> arenaTypes = [
    'desert', 'water', 'snow', 'hills', 'cave', 'beach', 'grass'
  ];

  final bool movesExpanded = true;

  bool isLoading = true;

  String? winnerTrainerName;

  bool hasHandledBattleEnd = false;

  String? playerTrainerName;
  String? opponentTrainerName;
  String? playerName;
  String? opponentName;

  @override
  void initState() {
    super.initState();
    // Stop menu music before starting battle music
    MusicService().stopMusic();
    playBattleMusic();
    isMusicPlaying = true;
    controller = null;
    _initTeams();
  }

  Future<void> _initTeams() async {
    setState(() { isLoading = true; });
    final supabase = Supabase.instance.client;
    // Fetch player trainer row
    final trainerRes = await supabase
      .from('trainer_table')
      .select()
      .eq('trainer_id', widget.trainerId)
      .maybeSingle(); // safer than .single()
    if (trainerRes == null) {
      setState(() { narration = "Trainer not found."; isLoading = false; });
      return;
    }
    playerTrainerName = trainerRes['username'] ?? 'You';
    playerName = playerTrainerName;
    // Get player team
    final playerTeam = await _fetchTeamFromTrainerRow(trainerRes);
    if (playerTeam.isEmpty) {
      setState(() {
        narration = "You have no Pokémon in your team. Please add Pokémon before battling.";
        isLoading = false;
      });
      return;
    }
    // Get random opponent trainer
    final trainers = await supabase
      .from('trainer_table')
      .select('trainer_id,username');
    final opponentIds = trainers.where((t) => t['trainer_id'] != widget.trainerId).toList();
    opponentIds.shuffle();
    final opponentId = opponentIds.isNotEmpty ? opponentIds.first['trainer_id'] : widget.trainerId;
    final opponentRes = await supabase
      .from('trainer_table')
      .select()
      .eq('trainer_id', opponentId)
      .maybeSingle(); // safer than .single()
    opponentTrainerName = opponentRes?['username'] ?? 'Opponent';
    opponentName = opponentTrainerName;
    final opponentTeam = await _fetchTeamFromTrainerRow(opponentRes ?? {});
    if (opponentTeam.isEmpty) {
      setState(() {
        narration = "Opponent has no Pokémon. Try again later.";
        isLoading = false;
      });
      return;
    }
    // Setup battle state
    final state = BattleGameState(
      playerTeam: playerTeam,
      opponentTeam: opponentTeam,
    );
    setState(() {
      controller = PokeBattleController(gameState: state);
      // Randomly select an arena type
      final rand = arenaTypes..shuffle();
      selectedArena = rand.first;
      selectedArenaText = selectedArena[0].toUpperCase() + selectedArena.substring(1);
      isLoading = false;
    });
  }

  Future<List<Pokemon_mcts>> _fetchTeamFromTrainerRow(Map trainerRow) async {
    final supabase = Supabase.instance.client;
    List<Pokemon_mcts> team = [];
    for (int i = 1; i <= 6; i++) {
      final slotKey = 'pokemon_slot_$i';
      final pokeId = trainerRow[slotKey];
      if (pokeId == null) continue;
      final pokeRes = await supabase
        .from('pokemon_table')
        .select()
        .eq('pokemon_id', pokeId)
        .maybeSingle(); // safer than .single()
      if (pokeRes == null) continue;
      // Fetch abilities
      List<Ability_mcts> abilities = [];
      for (int j = 1; j <= 4; j++) {
        final abKey = 'ability$j';
        final abId = pokeRes[abKey];
        if (abId == null) continue;
        final abRes = await supabase
          .from('abilities_table')
          .select()
          .eq('ability_id', abId)
          .maybeSingle(); // safer than .single()
        if (abRes == null) continue;
        abilities.add(Ability_mcts(
          name: abRes['ability_name'],
          type: abRes['type'],
          maxUses: abRes['uses'],
          hitRate: abRes['hitrate'],
          value: abRes['value'],
        ));
      }
      team.add(Pokemon_mcts(
        pokemonName: pokeRes['pokemon_name'],
        nickname: pokeRes['nickname'],
        type: pokeRes['type'],
        level: pokeRes['level'],
        attack: pokeRes['attack'],
        maxHealth: pokeRes['health'],
        abilities: abilities,
      ));
    }
    return team;
  }

  String getEffectivenessText(double multiplier) {
    if (multiplier >= 2.0) return "It's super effective!";
    if (multiplier >= 1.1) return "It's effective!";
    if (multiplier <= 0.5) return "It's not very effective...";
    return "";
  }



  Future<void> _handleBattleEnd() async {
    if (hasHandledBattleEnd) return;
    hasHandledBattleEnd = true;
    final supabase = Supabase.instance.client;
    final isWin = controller!.getWinner() == 1;
    final isLoss = controller!.getWinner() == -1;
    if (!isWin && !isLoss) return;
    final trainerRes = await supabase
      .from('trainer_table')
      .select()
      .eq('trainer_id', widget.trainerId)
      .maybeSingle();
    if (trainerRes == null) return;
    // Always set username before using it
    playerTrainerName = trainerRes['username'] ?? 'You';
    playerName = playerTrainerName;
    winnerTrainerName = isWin ? (playerName ?? 'You') : (opponentName ?? 'Opponent');
    int wins = trainerRes['wins'] ?? 0;
    int losses = trainerRes['losses'] ?? 0;
    int xp = trainerRes['experience_points'] ?? 0;
    int level = trainerRes['level'] ?? 1;
    int gainedXp = isWin ? 250 : 100;
    // Use battle context scaler (1.1) and base (100)
    final trainerXpResult = calculateXpAndLevel(
      currentXp: xp,
      currentLevel: level,
      xpChange: gainedXp,
      scaler: 1.1,
      base: 100,
    );
    xp = trainerXpResult.newXp;
    level = trainerXpResult.newLevel;
    bool trainerLeveledUp = trainerXpResult.levelsGained > 0;
    if (isWin) wins += 1;
    if (isLoss) losses += 1;
    await supabase
      .from('trainer_table')
      .update({
        'wins': wins,
        'losses': losses,
        'experience_points': xp,
        'level': level,
      })
      .eq('trainer_id', widget.trainerId);
    List<String> pokemonLevelUps = [];
    List<Future<void>> abilityDialogs = [];
    Set<String> slotPokeIds = {};
    for (int i = 1; i <= 6; i++) {
      final slotKey = 'pokemon_slot_$i';
      final pokeId = trainerRes[slotKey];
      if (pokeId == null) continue;
      slotPokeIds.add(pokeId.toString());
      final pokeRes = await supabase
        .from('pokemon_table')
        .select()
        .eq('pokemon_id', pokeId)
        .maybeSingle();
      if (pokeRes == null) continue;
      int pokeXp = pokeRes['experience_points'] ?? 0;
      int pokeLevel = pokeRes['level'] ?? 1;
      final pokeXpResult = calculateXpAndLevel(
        currentXp: pokeXp,
        currentLevel: pokeLevel,
        xpChange: gainedXp,
        scaler: 1.1,
        base: 100,
      );
      if (pokeXpResult.levelsGained > 0) {
        var tempPoke = Pokemon_mcts(
          pokemonName: pokeRes['pokemon_name'],
          nickname: pokeRes['nickname'],
          type: pokeRes['type'],
          level: pokeLevel,
          attack: pokeRes['attack'],
          maxHealth: pokeRes['health'],
          abilities: [],
        );
        for (int lvl = 0; lvl < pokeXpResult.levelsGained; lvl++) {
          tempPoke = tempPoke.levelUp();
        }
        String pokeName = pokeRes['nickname'] ?? pokeRes['pokemon_name'] ?? 'Pokémon';
        pokemonLevelUps.add('$pokeName (Lv${pokeLevel} → ${pokeXpResult.newLevel})');
        await supabase
          .from('pokemon_table')
          .update({
            'experience_points': pokeXpResult.newXp,
            'level': pokeXpResult.newLevel,
            'health': tempPoke.maxHealth,
            'attack': tempPoke.attack,
          })
          .eq('pokemon_id', pokeId);
      } else {
        await supabase
          .from('pokemon_table')
          .update({
            'experience_points': pokeXpResult.newXp,
            'level': pokeXpResult.newLevel,
          })
          .eq('pokemon_id', pokeId);
      }
      // Always fetch the latest ability IDs after level up
      if (pokeXpResult.levelsGained > 0 && pokeXpResult.newLevel % 5 == 0) {
        final updatedPokeRes = await supabase
          .from('pokemon_table')
          .select()
          .eq('pokemon_id', pokeId)
          .maybeSingle();
        List<String> currentAbilityIds = [];
        if (updatedPokeRes != null) {
          for (int j = 1; j <= 4; j++) {
            final abId = updatedPokeRes['ability$j'];
            if (abId != null) {
              currentAbilityIds.add(abId.toString());
            }
          }
        }
        final newAbility = await fetchRandomAbilityExcluding(currentAbilityIds);
        if (newAbility != null && mounted) {
          // Show ability dialog and wait for user action before continuing
          await offerAbilityDialog(
            context: context,
            ability: newAbility,
            pokeId: pokeId,
            currentAbilityIds: currentAbilityIds,
          );
        }
      }
    }
    // --- Favorite Pokémon XP logic ---
    final favoritePokeId = trainerRes['favorite_pokemon'];
    if (favoritePokeId != null) {
      int totalXpChange = slotPokeIds.contains(favoritePokeId.toString()) ? gainedXp * 2 : gainedXp;
      final pokeRes = await supabase
        .from('pokemon_table')
        .select()
        .eq('pokemon_id', favoritePokeId)
        .maybeSingle();
      if (pokeRes != null) {
        int pokeXp = pokeRes['experience_points'] ?? 0;
        int pokeLevel = pokeRes['level'] ?? 1;
        final pokeXpResult = calculateXpAndLevel(
          currentXp: pokeXp,
          currentLevel: pokeLevel,
          xpChange: totalXpChange,
          scaler: 1.1,
          base: 100,
        );
        await supabase
          .from('pokemon_table')
          .update({
            'experience_points': pokeXpResult.newXp,
            'level': pokeXpResult.newLevel,
          })
          .eq('pokemon_id', favoritePokeId);
      }
    }
    String msg = '';
    if (trainerLeveledUp) {
      msg += 'Trainer ${playerName ?? 'You'} leveled up!\n';
      // Add a random Pokémon to the trainer's team and show dialog
      final newPokeId = await addRandomPokemonToTrainer(widget.trainerId);
      if (newPokeId != null) {
        final pokeRes = await supabase
          .from('pokemon_table')
          .select()
          .eq('pokemon_id', newPokeId)
          .maybeSingle();
        if (pokeRes != null && mounted) {
          await showNewPokemonDialog(context, pokeRes['pokemon_name'], pokeRes['type']);
        }
      }
    }
    if (pokemonLevelUps.isNotEmpty) {
      msg += 'Pokémon leveled up: ${pokemonLevelUps.join(", ")}!';
    }
    if (!mounted) return;
    setState(() {
      narration = "${winnerTrainerName ?? 'Trainer'} wins!\n" + msg;
    });
    if (pokemonLevelUps.isNotEmpty && mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pokémon Leveled Up!'),
          content: Text(pokemonLevelUps.join('\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop('refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || controller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Pokémon Battle")),
        body: Center(child: narration.isNotEmpty ? Text(narration, style: TextStyle(fontSize: 18, color: Colors.red)) : const CircularProgressIndicator()),
      );
    }
    final activePlayer = controller!.state.getActive(true);
    final activeOpponent = controller!.state.getActive(false);
    if (controller!.isBattleOver) {
      _handleBattleEnd();
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Pokémon Battle")),
      backgroundColor: Colors.redAccent,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.redAccent,
        ),
        child: controller!.isBattleOver
            ? Center(
                child: Text(
                  // Show winnerTrainerName instead of "You win!"
                  controller!.getWinner() == 1
                      ? "${winnerTrainerName ?? 'Trainer'} wins!"
                      : controller!.getWinner() == -1
                          ? "You lose!"
                          : "Draw",
                  style: const TextStyle(fontSize: 24),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/background/' + selectedArena + '-battle-background.jpg'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              child: Column(
                                  children: [
                                  Stack(
                                    children:[
                                      _buildPokemonCard(activeOpponent, isOpponent: true),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(isMusicPlaying ? Icons.music_note : Icons.music_off),
                                            tooltip: isMusicPlaying ? 'Pause Music' : 'Play Music',
                                            onPressed: toggleMusic,
                                          ),
                                        ],
                                      ),
                                    ]
                                  ),
                                  // OPPONENT STATS

                                  const SizedBox(height: 16),

                                  // BATTLE ARENA
                                  Stack(
                                    children: [
                                      SizedBox(
                                        height: 140, // Set a fixed height for the battle arena
                                        child: Center(
                                          child: Column(
                                            children: [
                                              if (lastAiAction != null && lastAiAction!.startsWith("switch_"))
                                                Text(
                                                  "AI switched to "+activeOpponent.nickname+"!",
                                                  style: const TextStyle(
                                                    color: Colors.deepOrange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              const SizedBox(height: 8),
                                              Row( //  FIGHTING SCREEN
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: _buildAnimatedSprite(activePlayer, shake: opponentJustAttacked),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: _buildAnimatedSprite(activeOpponent, shake: playerJustAttacked),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isAnimating)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  "AI is thinking...",
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ]
                                  ),
                                  // PLAYER STATS
                                  _buildPokemonCard(activePlayer, isOpponent: false),

                                ]
                              )
                            ), // battle space
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.redAccent,
                        child: Column(
                          children: [
                            //MOVES AND OTHER STUFF
                            const SizedBox(height: 8),

                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              // NARRATION
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black54, width: 2),
                                ),
                                child: AnimatedTextKit(
                                  key: ValueKey(narration), // ensures animation restarts on narration change
                                  animatedTexts: [
                                    TyperAnimatedText(
                                      narration,
                                      textStyle: const TextStyle(color: Colors.black54, fontSize: 16),
                                      speed: const Duration(milliseconds: 35),
                                    ),
                                  ],
                                  totalRepeatCount: 1,
                                  pause: Duration.zero,
                                  displayFullTextOnTap: true,
                                  stopPauseOnTap: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // ACTIONS
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ExpansionTile(
                                  title: const Text("Moves", style: TextStyle(fontWeight: FontWeight.bold)),
                                  initiallyExpanded: movesExpanded,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black26, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: controller!.getValidActions().where((action) => action.startsWith("move_")).map((action) {
                                          final label = _getActionLabel(action);
                                          String usesInfo = "";
                                          final player = controller!.state.getActive(true);
                                          final index = int.tryParse(action.split("_")[1]) ?? 0;
                                          if (index >= 0 && index < player.abilities.length) {
                                            final ability = player.abilities[index];
                                            usesInfo = " (${ability.remainingUses}/${ability.maxUses})";
                                          }
                                          return ElevatedButton(
                                            onPressed: () => onPlayerAction(action),
                                            child: Text(label + usesInfo),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  title: const Text("Switch", style: TextStyle(fontWeight: FontWeight.bold)),
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black26, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: GridView.count(
                                        crossAxisCount: 2,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        childAspectRatio: 2.8,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        children: controller!.getValidActions().where((action) => action.startsWith("switch_")).map((action) {
                                          final label = _getActionLabel(action);
                                          final team = controller!.state.playerTeam;
                                          final index = int.tryParse(action.split("_")[1]) ?? 0;
                                          String hpInfo = "";
                                          if (index >= 0 && index < team.length) {
                                            final poke = team[index];
                                            hpInfo = "  HP: ${poke.currentHealth}/${poke.maxHealth}";
                                          }
                                          return ElevatedButton(
                                            onPressed: () => onPlayerAction(action),
                                            child: Text(label + hpInfo),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),


                            const SizedBox(height: 16),
                          ]
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  String _getActionLabel(String action) {
    final player = controller!.state.getActive(true);
    final team = controller!.state.playerTeam;

    if (action.startsWith("move_")) {
      final index = int.tryParse(action.split("_")[1]) ?? 0;
      if (index >= 0 && index < player.abilities.length) {
        return player.abilities[index].name;
      } else {
        return "Unknown Move";
      }
    } else if (action.startsWith("switch_")) {
      final index = int.tryParse(action.split("_")[1]) ?? 0;
      if (index >= 0 && index < team.length) {
        return team[index].nickname;
      } else {
        return "Unknown Switch";
      }
    }

    return action;
  }


  Widget _buildPokemonCard(Pokemon_mcts p, {required bool isOpponent}) {
    return Card(
      elevation: 2,
      color: p.isFainted ? Colors.grey[200] : (isOpponent ? Colors.red[100] : Colors.blue[100]),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${p.nickname} (${p.pokemonName})",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text("HP: ${p.currentHealth}/${p.maxHealth}"),
                const SizedBox(width: 16),
                Text("Type: ${p.type}"),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedHPBar(current: p.currentHealth, max: p.maxHealth),
          ],
        ),
      ),
      );
  }

  Widget _buildAnimatedSprite(Pokemon_mcts p, {bool shake = false}) {
    final spritePath = 'assets/sprites/${p.pokemonName.toLowerCase()}.png';

    return TweenAnimationBuilder<Offset>(
      key: ValueKey(p.nickname + p.currentHealth.toString()),
      tween: Tween<Offset>(
        begin: Offset.zero,
        end: shake ? const Offset(0.05, 0) : Offset.zero,
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.elasticIn,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(value.dx * 10, 0),
          child: Stack(
            children: [
              Image.asset(
                spritePath,
                width: 96,
                height: 96,
                errorBuilder: (context, error, stack) => const Icon(Icons.error),
              ),
              if (shake)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }


  String getAbilityName(String action, bool isPlayer) {
    if (!action.startsWith("move_")) return "";
    final index = int.parse(action.split("_")[1]);
    final p = controller!.state.getActive(isPlayer);
    return p.abilities[index].name;
  }


  Future<void> playTurnAnimationSequence(String playerAction) async {
    setState(() {
      playerJustAttacked = playerAction.startsWith("move_");
      opponentJustAttacked = false;
      narration = "You used ${getAbilityName(playerAction, true)}!";
      isAnimating = true;
    });

    // Pause to show player attack + shake
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      controller!.applyPlayerAction(playerAction);
      // After controller.applyPlayerAction(playerAction);
      final effectiveness = controller!.lastEffectiveness;
      final feedback = getEffectivenessText(effectiveness);

      setState(() {
        narration += "\n$feedback";
      });

    });

    if (!controller!.isBattleOver) {
      final aiAction = runMCTS(controller!.state, 100);
      final isSwitch = aiAction.startsWith("switch_");
      final aiUsed = isSwitch
          ? "AI switched to ${controller!.state.getActive(false).nickname}!"
          : "Enemy used ${getAbilityName(aiAction, false)}!";

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        narration = aiUsed;
        opponentJustAttacked = !isSwitch;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        controller!.state.applyAction(aiAction);
        isAnimating = false;
      });
    } else {
      setState(() {
        isAnimating = false;
      });
    }
  }

  void playBattleMusic() {
    MusicService().playMusic('music/battle_music.mp3');
  }

  void toggleMusic() {
    setState(() {
      isMusicPlaying = !isMusicPlaying;
      if (isMusicPlaying) {
        MusicService().playMusic('music/battle_music.mp3');
      } else {
        MusicService().stopMusic();
      }
    });
  }

  void onPlayerAction(String action) {
    playTurnAnimationSequence(action);
  }


  @override
  void dispose() {
    // Stop battle music and resume menu music when leaving the page
    MusicService().stopMusic(); // Stop battle music
    MusicService().playMusic('music/menu_music.mp3'); // Resume menu music
    super.dispose();
  }
}
class AnimatedHPBar extends StatelessWidget {
  final int current;
  final int max;

  const AnimatedHPBar({super.key, required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final ratio = current / max;
    final color = ratio > 0.5
        ? Colors.green
        : ratio > 0.2
        ? Colors.orange
        : Colors.red;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: ratio),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, _) {
        return SizedBox(
          width: 170, // or MediaQuery.of(context).size.width * 0.4 for responsive
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[300],
              color: color,
              minHeight: 12,
            ),
          ),
        );
      },
    );
  }
}
