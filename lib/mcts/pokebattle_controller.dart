// lib/controllers/pokebattle_controller.dart

import '../models/battle_game_state.dart';
import '../mcts/mcts_search.dart';

class PokeBattleController {
  BattleGameState gameState;

  PokeBattleController({required this.gameState});

  bool get isPlayerTurn => gameState.isPlayerTurn;

  bool get isBattleOver => gameState.isTerminal;

  double lastEffectiveness = 1.0;


  List<String> getValidActions() {
    return gameState.getValidActions();
  }

  void applyPlayerAction(String action) {
    if (!isPlayerTurn) return;
    if (action.startsWith("move_")) {
      lastEffectiveness = state.previewEffectiveness(action);
    }
    state.applyAction(action);
  }


  void applyAIAction() {
    if (isPlayerTurn || isBattleOver) return;
    final action = runMCTS(gameState, 100);
    gameState.applyAction(action);
  }

  int getWinner() {
    return gameState.evaluate(); // 1 = player win, -1 = loss, 0 = ongoing
  }

  BattleGameState get state => gameState;
}
