// Utility for XP and level-up logic for both trainers and Pokémon.
// Allows different scalers and XP values for different contexts (battle, task, etc).

class XpLevelResult {
  final int newXp;
  final int newLevel;
  final int levelsGained;
  XpLevelResult({required this.newXp, required this.newLevel, required this.levelsGained});
}

/// Calculates new XP and level after gaining/losing XP.
/// [currentXp]: current experience points
/// [currentLevel]: current level
/// [xpChange]: XP to add (can be negative)
/// [scaler]: multiplier for level-up threshold (e.g. 1.1 or 1.2)
/// [base]: base XP per level (usually 100)
XpLevelResult calculateXpAndLevel({
  required int currentXp,
  required int currentLevel,
  required int xpChange,
  double scaler = 1.1,
  int base = 100,
}) {
  int xp = (currentXp + xpChange).clamp(0, 1 << 30);
  int level = currentLevel;
  int levelsGained = 0;
  int threshold = (base * level * scaler).ceil();
  while (xp >= threshold) {
    xp -= threshold;
    level += 1;
    levelsGained += 1;
    threshold = (base * level * scaler).ceil();
  }
  return XpLevelResult(newXp: xp, newLevel: level, levelsGained: levelsGained);
}

