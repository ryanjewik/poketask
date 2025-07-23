import 'dart:math';
import 'pokemon_mcts.dart';

class BattleGameState {
  final List<Pokemon_mcts> playerTeam;
  final List<Pokemon_mcts> opponentTeam;
  int playerActive;
  int opponentActive;
  bool isPlayerTurn;

  BattleGameState({
    required this.playerTeam,
    required this.opponentTeam,
    this.playerActive = 0,
    this.opponentActive = 0,
    this.isPlayerTurn = true,
  });

  BattleGameState clone() {
    return BattleGameState(
      playerTeam: playerTeam.map((p) => p.clone()).toList(),
      opponentTeam: opponentTeam.map((p) => p.clone()).toList(),
      playerActive: playerActive,
      opponentActive: opponentActive,
      isPlayerTurn: isPlayerTurn,
    );
  }

  Pokemon_mcts getActive(bool forPlayer) {
    return forPlayer ? playerTeam[playerActive] : opponentTeam[opponentActive];
  }

  List<String> getValidActions() {
    final actions = <String>[];
    final active = getActive(isPlayerTurn);
    final team = isPlayerTurn ? playerTeam : opponentTeam;
    final activeIndex = isPlayerTurn ? playerActive : opponentActive;

    // If active Pokémon is fainted, only allow switches
    if (active.isFainted) {
      for (int i = 0; i < team.length; i++) {
        if (i != activeIndex && !team[i].isFainted) {
          actions.add("switch_$i");
        }
      }
      return actions;
    }

    // Otherwise, allow moves and switches
    for (int i = 0; i < active.abilities.length; i++) {
      if (active.abilities[i].remainingUses > 0) {
        actions.add("move_$i");
      }
    }
    for (int i = 0; i < team.length; i++) {
      if (i != activeIndex && !team[i].isFainted) {
        actions.add("switch_$i");
      }
    }
    return actions;
  }

  void applyAction(String action) {
    final active = getActive(isPlayerTurn);
    // Prevent moves if active Pokémon is fainted
    if (active.isFainted && action.startsWith("move_")) {
      return;
    }
    if (action.startsWith("move_")) {
      final index = int.parse(action.split("_")[1]);
      _applyMove(index);
    } else if (action.startsWith("switch_")) {
      final index = int.parse(action.split("_")[1]);
      if (isPlayerTurn) {
        playerActive = index;
      } else {
        opponentActive = index;
      }
      isPlayerTurn = !isPlayerTurn;
    }
  }

  void _applyMove(int index) {
    final attacker = getActive(isPlayerTurn);
    final defender = getActive(!isPlayerTurn);
    final move = attacker.abilities[index];

    if (move.remainingUses == 0) return;

    move.remainingUses -= 1;

    if (Random().nextInt(100) >= move.hitRate) {
      isPlayerTurn = !isPlayerTurn;
      return; // Missed
    }

    final multiplier = _getTypeEffectiveness(move.type, defender.type);
    // New damage formula: (ability value + (pokemon attack * 0.1)) * type multiplier, rounded down
    final rawDamage = (move.value + (attacker.attack * 0.1)) * multiplier;
    final damage = rawDamage.floor();
    defender.currentHealth -= damage;
    isPlayerTurn = !isPlayerTurn;
  }

  double _getTypeEffectiveness(String atk, String def) {
    final chart = {
      'Fire': {'Grass': 1.5, 'Water': 0.7, 'Rock': 0.7, 'Ice': 1.5, 'Bug': 1.2},
      'Water': {'Fire': 1.5, 'Electric': 0.7, 'Rock': 1.2, 'Ground': 1.2, 'Grass': 0.7},
      'Electric': {'Water': 1.5, 'Grass': 0.7, 'Flying': 1.2, 'Ground': 0.7},
      'Grass': {'Water': 1.5, 'Fire': 0.7, 'Ground': 1.2, 'Rock': 1.2, 'Bug': 0.7},
      'Rock': {'Fire': 1.2, 'Flying': 1.2, 'Bug': 1.2, 'Fighting': 0.7, 'Ground': 0.7},
      'Ground': {'Fire': 1.2, 'Electric': 1.5, 'Rock': 1.2, 'Grass': 0.7, 'Bug': 0.7},
      'Flying': {'Grass': 1.2, 'Electric': 0.7, 'Bug': 1.2, 'Rock': 0.7},
      'Bug': {'Grass': 1.2, 'Fire': 0.7, 'Flying': 0.7, 'Rock': 0.7},
      'Ice': {'Grass': 1.2, 'Ground': 1.2, 'Flying': 1.2, 'Water': 0.7, 'Fire': 0.7},
      'Fighting': {'Rock': 1.2, 'Ice': 1.2, 'Flying': 0.7, 'Psychic': 0.7},
      'Psychic': {'Fighting': 1.2, 'Poison': 1.2, 'Psychic': 0.7},
      'Poison': {'Grass': 1.2, 'Poison': 0.7, 'Ground': 0.7, 'Rock': 0.7},
      // Add more types as needed
    };
    return chart[atk]?[def] ?? 1.0;
  }

  bool get isTerminal {
    final playerAlive = playerTeam.any((p) => !p.isFainted);
    final opponentAlive = opponentTeam.any((p) => !p.isFainted);
    return !playerAlive || !opponentAlive;
  }

  int evaluate() {
    int score = 0;

    for (final p in playerTeam) {
      if (!p.isFainted) {
        score += 5; // reward each conscious Pokémon
        score += (p.currentHealth ~/ 5); // reward remaining HP
      }
    }

    for (final o in opponentTeam) {
      if (!o.isFainted) {
        score -= 5;
        score -= (o.currentHealth ~/ 5);
      }
    }

    return score.sign; // Returns -1, 0, or 1 (same as before)
  }

  double previewEffectiveness(String moveAction) {
    if (!moveAction.startsWith("move_")) return 1.0;
    final moveIndex = int.parse(moveAction.split('_')[1]);
    final attacker = getActive(isPlayerTurn);
    final defender = getActive(!isPlayerTurn);
    final move = attacker.abilities[moveIndex];
    return _getTypeEffectiveness(move.type, defender.type);
  }

}
