class Pokemon {
  Pokemon({
    required this.pokemonId,
    required this.dateCaught,
    required this.pokemonName,
    required this.nickname,
    required this.type,
    required this.level,
    required this.experiencePoints,
    required this.trainerId,
    required this.attack,
    required this.health,
    required this.ability1,
    required this.ability2,
    required this.ability3,
    required this.ability4,
  });

  String pokemonId;
  DateTime dateCaught;
  String pokemonName;
  String nickname;
  String type;
  int level;
  int experiencePoints;
  String trainerId;
  int attack;
  int health;
  String ability1;
  String ability2;
  String ability3;
  String ability4;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      pokemonId: json['pokemon_id']?.toString() ?? '',
      dateCaught: DateTime.tryParse(json['date_caught'] ?? '') ?? DateTime.now(),
      pokemonName: json['pokemon_name'] ?? '',
      nickname: json['nickname'] ?? '',
      type: json['type'] ?? '',
      level: json['level'] ?? 1,
      experiencePoints: json['experience_points'] ?? 0,
      trainerId: json['trainer_id']?.toString() ?? '',
      attack: json['attack'] ?? 0,
      health: json['health'] ?? 0,
      ability1: json['ability1']?.toString() ?? '',
      ability2: json['ability2']?.toString() ?? '',
      ability3: json['ability3']?.toString() ?? '',
      ability4: json['ability4']?.toString() ?? '',
    );
  }

}