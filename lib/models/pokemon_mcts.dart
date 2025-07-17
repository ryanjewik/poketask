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
}
