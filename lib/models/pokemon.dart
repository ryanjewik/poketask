

class Pokemon {
  Pokemon({
    required this.pokemonName,
    required this.nickname,
    required this.pokemonId,
    required this.pokemonType,
    this.level = 1,
    this.ability1 = -1,
    this.ability2 = -1,
    this.ability3 = -1,
    this.ability4 = -1,
    required this.trainerId,
    this.dateCaptured = '',
    this.attack = 100,
    this.defense = 100,
});

  String pokemonName;
  String nickname;
  int pokemonId;
  String pokemonType;
  int level;
  int ability1;
  int ability2;
  int ability3;
  int ability4;
  int trainerId;
  String dateCaptured;
  int attack;
  int defense;

  @override
  String toString() {
    return 'Pokemon{pokemonName: $pokemonName, nickname: $nickname, pokemonId: $pokemonId, pokemonType: $pokemonType, level: $level, abilities: [$ability1, $ability2, $ability3, $ability4], trainerId: $trainerId, dateCaptured: $dateCaptured, attack: $attack, defense: $defense}';
  }
}