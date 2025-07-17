class Ability_mcts {
  final String name;
  final String type;
  final int maxUses;
  final int hitRate; // 1–100
  final int value; // 0 = special effect, >0 = damage
  int remainingUses;

  Ability_mcts({
    required this.name,
    required this.type,
    required this.maxUses,
    required this.hitRate,
    required this.value,
  }) : remainingUses = maxUses;

  Ability_mcts clone() {
    return Ability_mcts(
      name: name,
      type: type,
      maxUses: maxUses,
      hitRate: hitRate,
      value: value,
    )..remainingUses = remainingUses;
  }
}
