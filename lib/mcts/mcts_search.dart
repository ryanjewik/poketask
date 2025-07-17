import '../models/battle_game_state.dart';
import 'mcts_node.dart';
import 'dart:math';

String runMCTS(BattleGameState rootState, int iterations) {
  final root = MCTSNode(state: rootState.clone());

  for (int i = 0; i < iterations; i++) {
    MCTSNode node = root;

    // STEP 1: SELECTION
    while (node.children.isNotEmpty && node.isFullyExpanded) {
      node = node.children.reduce((a, b) =>
      a.ucb1(root.visits) > b.ucb1(root.visits) ? a : b);
    }

    // STEP 2: EXPANSION
    if (!node.state.isTerminal) {
      final untried = node.state.getValidActions().where((a) =>
          node.children.every((c) => c.action != a)).toList();

      if (untried.isNotEmpty) {
        final action = untried[Random().nextInt(untried.length)];
        final newState = node.state.clone();
        newState.applyAction(action);
        final child = MCTSNode(state: newState, parent: node, action: action);
        node.children.add(child);
        node = child;
      }
    }

    // STEP 3: SIMULATION
    final result = simulateRandomPlayout(node.state.clone());

    // 🎯 EARLY EXIT PRUNING
    if (result == 1 && node.parent == root) {
      // If this is a player win from a root move → exit early
      return node.action!;
    }

    // STEP 4: BACKPROPAGATION
    MCTSNode? backNode = node;
    while (backNode != null) {
      backNode.visits++;
      if (result == 1) backNode.wins++;
      backNode = backNode.parent;
    }
  }

  // Default return: pick most visited action
  final MCTSNode? best = root.children.isNotEmpty ? root.children.reduce((a, b) => a.visits > b.visits ? a : b) : null;
  return best?.action ?? '';
}

int simulateRandomPlayout(BattleGameState state) {
  while (!state.isTerminal) {
    final actions = state.getValidActions();
    if (actions.isEmpty) break;
    final action = actions[Random().nextInt(actions.length)];
    state.applyAction(action);
  }
  return state.evaluate(); // 1 = win, -1 = loss, 0 = undecided
}
