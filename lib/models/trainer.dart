class Trainer {
  Trainer({
    required this.trainerId,
    required this.createdAt,
    required this.sex,
    required this.username,
    required this.wins,
    required this.losses,
    required this.experiencePoints,
    required this.level,
    required this.pokemonSlot1,
    required this.pokemonSlot2,
    required this.pokemonSlot3,
    required this.pokemonSlot4,
    required this.pokemonSlot5,
    required this.pokemonSlot6,
    required this.favoritePokemon,
    required this.completedTasks,
  });

  String trainerId;
  DateTime createdAt;
  String sex;
  String username;
  int wins;
  int losses;
  int experiencePoints;
  int level;
  String pokemonSlot1;
  String pokemonSlot2;
  String pokemonSlot3;
  String pokemonSlot4;
  String pokemonSlot5;
  String pokemonSlot6;
  String favoritePokemon;
  int completedTasks;

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      trainerId: json['trainer_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      sex: json['sex'] ?? '',
      username: json['username'] ?? '',
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      experiencePoints: json['experience_points'] ?? 0,
      level: json['level'] ?? 1,
      pokemonSlot1: json['pokemon_slot_1']?.toString() ?? '',
      pokemonSlot2: json['pokemon_slot_2']?.toString() ?? '',
      pokemonSlot3: json['pokemon_slot_3']?.toString() ?? '',
      pokemonSlot4: json['pokemon_slot_4']?.toString() ?? '',
      pokemonSlot5: json['pokemon_slot_5']?.toString() ?? '',
      pokemonSlot6: json['pokemon_slot_6']?.toString() ?? '',
      favoritePokemon: json['favorite_pokemon']?.toString() ?? '',
      completedTasks: json['completed_tasks'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'Trainer{trainerId: $trainerId, username: $username, sex: $sex, wins: $wins, losses: $losses, experiencePoints: $experiencePoints, level: $level, favoritePokemon: $favoritePokemon, completedTasks: $completedTasks}';
  }
}