import 'dart:math';

import '../models/battle_game_state.dart';

class MCTSNode {
  final BattleGameState state;
  final MCTSNode? parent;
  final String? action;
  final List<MCTSNode> children = [];

  int visits = 0;
  int wins = 0;

  MCTSNode({
    required this.state,
    this.parent,
    this.action,
  });

  double ucb1(int totalSimulations, {double c = 1.41}) {
    if (visits == 0) return double.infinity;
    return (wins / visits) + c * (sqrt(log(totalSimulations + 1) / visits));
  }

  bool get isFullyExpanded => children.length == state.getValidActions().length;
}
