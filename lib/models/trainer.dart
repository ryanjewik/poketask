
class Trainer {
  Trainer({
    required this.trainerName,
    required this.trainerId,
    this.pokemonCount = 0,
    this.dateJoined = '',
    this.level = 1,
    this.experiencePoints = 0,
    this.sex = 'Unknown',
    this.wins = 0,
    this.losses = 0,
    this.completedTasks = 0,
    this.pokemonSlot1 = 0,
    this.pokemonSlot2 = -1,
    this.pokemonSlot3 = -1,
    this.pokemonSlot4 = -1,
    this.pokemonSlot5 = -1,
    this.pokemonSlot6 = -1,
  });

  String trainerName;
  int trainerId;
  int pokemonCount;
  String dateJoined;
  int level;
  int experiencePoints;
  String sex;
  int wins;
  int losses;
  int completedTasks;
  int pokemonSlot1;
  int pokemonSlot2;
  int pokemonSlot3;
  int pokemonSlot4;
  int pokemonSlot5;
  int pokemonSlot6;

  @override
  String toString() {
    return 'Trainer{trainerName: $trainerName, trainerId: $trainerId, pokemonCount: $pokemonCount, dateJoined: $dateJoined, level: $level, experiencePoints: $experiencePoints}';
  }
}