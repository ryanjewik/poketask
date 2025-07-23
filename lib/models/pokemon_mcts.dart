import 'ability_mcts.dart';

class Pokemon_mcts {
  final String pokemonName;
  final String nickname;
  final String type;
  final int level;
  final int attack;
  final int maxHealth;
  int currentHealth;
  final List<Ability_mcts> abilities;

  Pokemon_mcts({
    required this.pokemonName,
    required this.nickname,
    required this.type,
    required this.level,
    required this.attack,
    required this.maxHealth,
    required this.abilities,
  }) : currentHealth = maxHealth;

  bool get isFainted => currentHealth <= 0;

  Pokemon_mcts clone() {
    return Pokemon_mcts(
      pokemonName: pokemonName,
      nickname: nickname,
      type: type,
      level: level,
      attack: attack,
      maxHealth: maxHealth,
      abilities: abilities.map((a) => a.clone()).toList(),
    )..currentHealth = currentHealth;
  }

  // Level up stats by multiplying by 1.1 and rounding down
  Pokemon_mcts levelUp() {
    final newAttack = (attack * 1.1).floor();
    final newMaxHealth = (maxHealth * 1.1).floor();
    return Pokemon_mcts(
      pokemonName: pokemonName,
      nickname: nickname,
      type: type,
      level: level + 1,
      attack: newAttack,
      maxHealth: newMaxHealth,
      abilities: abilities.map((a) => a.clone()).toList(),
    )..currentHealth = newMaxHealth;
  }
}
