import 'package:flutter/material.dart';
import '../mcts/pokebattle_controller.dart';
import '../models/battle_game_state.dart';
import '../models/pokemon_mcts.dart';
import '../models/ability_mcts.dart';
import '../mcts/mcts_search.dart'; // For direct MCTS call
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/music_service.dart';


class PokeBattlePage extends StatefulWidget {
  final String trainerId;
  const PokeBattlePage({super.key, required this.trainerId});

  @override
  State<PokeBattlePage> createState() => _PokeBattlePageState();
}

class _PokeBattlePageState extends State<PokeBattlePage> {
  late PokeBattleController controller;
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

  // Fix: Add movesExpanded to control ExpansionTile state
  final bool movesExpanded = true;

  String getEffectivenessText(double multiplier) {
    if (multiplier >= 2.0) return "It's super effective!";
    if (multiplier >= 1.1) return "It's effective!";
    if (multiplier <= 0.5) return "It's not very effective...";
    return "";
  }



  @override
  void initState() {
    super.initState();
    playBattleMusic();
    isMusicPlaying = true;

    final squirtle = Pokemon_mcts(
      pokemonName: "Squirtle",
      nickname: "Bubbles",
      type: "Water",
      level: 5,
      attack: 10,
      maxHealth: 35,
      abilities: [
        Ability_mcts(name: "Water Gun", type: "Water", maxUses: 10, hitRate: 90, value: 12),
        Ability_mcts(name: "Tackle", type: "Normal", maxUses: 15, hitRate: 100, value: 10),
        Ability_mcts(name: "Bubble", type: "Water", maxUses: 10, hitRate: 95, value: 10),
        Ability_mcts(name: "Withdraw", type: "Water", maxUses: 10, hitRate: 100, value: 0),
      ],
    );

    final bulbasaur = Pokemon_mcts(
      pokemonName: "Bulbasaur",
      nickname: "Leafy",
      type: "Grass",
      level: 5,
      attack: 9,
      maxHealth: 38,
      abilities: [
        Ability_mcts(name: "Vine Whip", type: "Grass", maxUses: 10, hitRate: 90, value: 13),
        Ability_mcts(name: "Growl", type: "Normal", maxUses: 10, hitRate: 100, value: 0),
        Ability_mcts(name: "Tackle", type: "Normal", maxUses: 15, hitRate: 100, value: 10),
        Ability_mcts(name: "Leech Seed", type: "Grass", maxUses: 10, hitRate: 90, value: 8),
      ],
    );

    final pikachu = Pokemon_mcts(
      pokemonName: "Pikachu",
      nickname: "Zappy",
      type: "Electric",
      level: 5,
      attack: 11,
      maxHealth: 32,
      abilities: [
        Ability_mcts(name: "Thunder Shock", type: "Electric", maxUses: 10, hitRate: 90, value: 14),
        Ability_mcts(name: "Quick Attack", type: "Normal", maxUses: 15, hitRate: 100, value: 10),
        Ability_mcts(name: "Tail Whip", type: "Normal", maxUses: 10, hitRate: 100, value: 0),
        Ability_mcts(name: "Electro Ball", type: "Electric", maxUses: 10, hitRate: 90, value: 16),
      ],
    );

    final charmander = Pokemon_mcts(
      pokemonName: "Charmander",
      nickname: "Flamey",
      type: "Fire",
      level: 5,
      attack: 12,
      maxHealth: 33,
      abilities: [
        Ability_mcts(name: "Ember", type: "Fire", maxUses: 10, hitRate: 90, value: 13),
        Ability_mcts(name: "Scratch", type: "Normal", maxUses: 15, hitRate: 100, value: 9),
        Ability_mcts(name: "Growl", type: "Normal", maxUses: 10, hitRate: 100, value: 0),
        Ability_mcts(name: "Dragon Breath", type: "Dragon", maxUses: 10, hitRate: 90, value: 15),
      ],
    );

    final pidgey = Pokemon_mcts(
      pokemonName: "Pidgey",
      nickname: "Wings",
      type: "Normal",
      level: 5,
      attack: 8,
      maxHealth: 30,
      abilities: [
        Ability_mcts(name: "Gust", type: "Normal", maxUses: 15, hitRate: 95, value: 11),
        Ability_mcts(name: "Sand Attack", type: "Ground", maxUses: 10, hitRate: 100, value: 0),
        Ability_mcts(name: "Quick Attack", type: "Normal", maxUses: 15, hitRate: 100, value: 10),
        Ability_mcts(name: "Wing Attack", type: "Flying", maxUses: 10, hitRate: 95, value: 13),
      ],
    );

    final geodude = Pokemon_mcts(
      pokemonName: "Geodude",
      nickname: "Rocky",
      type: "Rock",
      level: 5,
      attack: 13,
      maxHealth: 40,
      abilities: [
        Ability_mcts(name: "Rock Throw", type: "Rock", maxUses: 10, hitRate: 90, value: 15),
        Ability_mcts(name: "Defense Curl", type: "Normal", maxUses: 10, hitRate: 100, value: 0),
        Ability_mcts(name: "Tackle", type: "Normal", maxUses: 15, hitRate: 100, value: 10),
        Ability_mcts(name: "Magnitude", type: "Ground", maxUses: 10, hitRate: 90, value: 17),
      ],
    );

    // Add 3 more Pokémon for each team
    final eevee = Pokemon_mcts(
      pokemonName: "Eevee",
      nickname: "Fuzzy",
      type: "Normal",
      level: 5,
      attack: 10,
      maxHealth: 34,
      abilities: [
        Ability_mcts(name: "Tackle", type: "Normal", maxUses: 15, hitRate: 100, value: 10),
        Ability_mcts(name: "Quick Attack", type: "Normal", maxUses: 15, hitRate: 100, value: 10),
        Ability_mcts(name: "Sand Attack", type: "Ground", maxUses: 10, hitRate: 100, value: 0),
        Ability_mcts(name: "Swift", type: "Normal", maxUses: 10, hitRate: 100, value: 12),
      ],
    );
    final jigglypuff = Pokemon_mcts(
      pokemonName: "Jigglypuff",
      nickname: "Puffy",
      type: "Fairy",
      level: 5,
      attack: 8,
      maxHealth: 38,
      abilities: [
        Ability_mcts(name: "Sing", type: "Normal", maxUses: 10, hitRate: 80, value: 0),
        Ability_mcts(name: "Pound", type: "Normal", maxUses: 15, hitRate: 100, value: 10),
        Ability_mcts(name: "Defense Curl", type: "Normal", maxUses: 10, hitRate: 100, value: 0),
        Ability_mcts(name: "Disarming Voice", type: "Fairy", maxUses: 10, hitRate: 100, value: 13),
      ],
    );
    final machop = Pokemon_mcts(
      pokemonName: "Machop",
      nickname: "Muscle",
      type: "Fighting",
      level: 5,
      attack: 13,
      maxHealth: 36,
      abilities: [
        Ability_mcts(name: "Karate Chop", type: "Fighting", maxUses: 10, hitRate: 95, value: 14),
        Ability_mcts(name: "Low Kick", type: "Fighting", maxUses: 10, hitRate: 90, value: 13),
        Ability_mcts(name: "Leer", type: "Normal", maxUses: 10, hitRate: 100, value: 0),
        Ability_mcts(name: "Focus Energy", type: "Normal", maxUses: 10, hitRate: 100, value: 0),
      ],
    );

    final playerTeam = [squirtle, bulbasaur, pikachu, eevee, jigglypuff, machop];
    final opponentTeam = [charmander, pidgey, geodude, eevee, jigglypuff, machop];

    final state = BattleGameState(
      playerTeam: playerTeam,
      opponentTeam: opponentTeam,
    );

    controller = PokeBattleController(gameState: state);

    // Randomly select an arena type
    final rand = arenaTypes..shuffle();
    selectedArena = rand.first;
    selectedArenaText = selectedArena[0].toUpperCase() + selectedArena.substring(1);
  }

  Future<void> playBattleMusic() async {
    await MusicService().stopMusic();
    await MusicService().playMusic('music/battle_music.mp3');
  }


  void onPlayerAction(String action) {
    if (isAnimating || controller.isBattleOver) return;
    playTurnAnimationSequence(action);
  }

  void toggleMusic() async {
    if (isMusicPlaying) {
      await MusicService().stopMusic();
    } else {
      await MusicService().playMusic('music/battle_music.mp3');
    }
    setState(() {
      isMusicPlaying = !isMusicPlaying;
    });
  }


  @override
  Widget build(BuildContext context) {
    final activePlayer = controller.state.getActive(true);
    final activeOpponent = controller.state.getActive(false);

    return Scaffold(
      appBar: AppBar(title: const Text("Pokémon Battle")),
      backgroundColor: Colors.redAccent,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.redAccent,
        ),
        child: controller.isBattleOver
            ? Center(
                child: Text(
                  controller.getWinner() == 1
                      ? "You win!"
                      : controller.getWinner() == -1
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
                                        children: controller.getValidActions().where((action) => action.startsWith("move_")).map((action) {
                                          final label = _getActionLabel(action);
                                          String usesInfo = "";
                                          final player = controller.state.getActive(true);
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
                                        children: controller.getValidActions().where((action) => action.startsWith("switch_")).map((action) {
                                          final label = _getActionLabel(action);
                                          final team = controller.state.playerTeam;
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
    final player = controller.state.getActive(true);
    final team = controller.state.playerTeam;

    if (action.startsWith("move_")) {
      final index = int.tryParse(action.split("_")[1]) ?? 0;
      return player.abilities[index].name;
    } else if (action.startsWith("switch_")) {
      final index = int.tryParse(action.split("_")[1]) ?? 0;
      return team[index].nickname;
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
    final p = controller.state.getActive(isPlayer);
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
      controller.applyPlayerAction(playerAction);
      // After controller.applyPlayerAction(playerAction);
      final effectiveness = controller.lastEffectiveness;
      final feedback = getEffectivenessText(effectiveness);

      setState(() {
        narration += "\n$feedback";
      });

    });

    if (!controller.isBattleOver) {
      final aiAction = runMCTS(controller.state, 100);
      final isSwitch = aiAction.startsWith("switch_");
      final aiUsed = isSwitch
          ? "AI switched to ${controller.state.getActive(false).nickname}!"
          : "Enemy used ${getAbilityName(aiAction, false)}!";

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        narration = aiUsed;
        opponentJustAttacked = !isSwitch;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        controller.state.applyAction(aiAction);
        isAnimating = false;
      });
    } else {
      setState(() {
        isAnimating = false;
      });
    }
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
