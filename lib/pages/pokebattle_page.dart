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
      ],
    );

    final playerTeam = [squirtle, bulbasaur, pikachu];
    final opponentTeam = [charmander, pidgey, geodude];

    final state = BattleGameState(
      playerTeam: playerTeam,
      opponentTeam: opponentTeam,
    );

    controller = PokeBattleController(gameState: state);
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
      body: controller.isBattleOver
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
                    // Music toggle button at the top right
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

                    // OPPONENT STATS
                    _buildPokemonCard(activeOpponent, isOpponent: true),
                    const SizedBox(height: 16),

                    // BATTLE ARENA
                    SizedBox(
                      height: 180, // Set a fixed height for the battle arena
                      child: Center(
                        child: Column(
                          children: [
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

                            if (lastAiAction != null && lastAiAction!.startsWith("switch_"))
                              Text(
                                "AI switched to "+activeOpponent.nickname+"!",
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: _buildAnimatedSprite(activeOpponent, shake: playerJustAttacked),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: _buildAnimatedSprite(activePlayer, shake: opponentJustAttacked),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),


                    // PLAYER STATS
                    _buildPokemonCard(activePlayer, isOpponent: false),

                    const SizedBox(height: 8),

                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AnimatedTextKit(
                        key: ValueKey(narration), // ensures animation restarts on narration change
                        animatedTexts: [
                          TyperAnimatedText(
                            narration,
                            textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                            speed: const Duration(milliseconds: 35),
                          ),
                        ],
                        totalRepeatCount: 1,
                        pause: Duration.zero,
                        displayFullTextOnTap: true,
                        stopPauseOnTap: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Battle Icon
                    const Icon(Icons.sports_martial_arts, size: 48),
                    // ACTIONS
                    const Text("Choose your move:"),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.getValidActions().map((action) {
                        final label = _getActionLabel(action);
                        return ElevatedButton(
                          onPressed: () => onPlayerAction(action),
                          child: Text(label),
                        );
                      }).toList(),
                    ),


                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: const Text("Your Team"),
                      children: [_buildTeamView(controller.state.playerTeam, controller.state.playerActive)],
                    ),
                    ExpansionTile(
                      title: const Text("Opponent Team"),
                      children: [_buildTeamView(controller.state.opponentTeam, controller.state.opponentActive)],
                    ),
                  ],
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


  Widget _buildTeamView(List<Pokemon_mcts> team, int activeIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: team.asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        final isActive = i == activeIndex;
        final status = p.isFainted
            ? " (Fainted)"
            : isActive
            ? " (Active)"
            : "";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${p.nickname}: ${p.currentHealth}/${p.maxHealth}$status",
              style: TextStyle(
                color: p.isFainted ? Colors.grey : Colors.black,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (!p.isFainted)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: p.abilities.map((ability) {
                    return Text(
                      "- ${ability.name} (${ability.remainingUses}/${ability.maxUses})",
                      style: const TextStyle(fontSize: 12),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPokemonCard(Pokemon_mcts p, {required bool isOpponent}) {
    final spritePath = 'assets/sprites/${p.pokemonName.toLowerCase()}.png';

    return Card(
      elevation: 2,
      color: p.isFainted ? Colors.grey[200] : (isOpponent ? Colors.red[100] : Colors.blue[100]),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(spritePath, width: 64, height: 64, fit: BoxFit.contain),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${p.nickname} (${p.pokemonName})",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Type: ${p.type}"),
                    Text("HP: ${p.currentHealth}/${p.maxHealth}"),
                    AnimatedHPBar(current: p.currentHealth, max: p.maxHealth),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("Abilities:"),
            ...p.abilities.map((a) =>
                Text("- ${a.name} (${a.remainingUses}/${a.maxUses})")).toList(),
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
          width: 120, // or MediaQuery.of(context).size.width * 0.4 for responsive
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
