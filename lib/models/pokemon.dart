

class Pokemon {
  Pokemon({
    required this.pokemonName,
    required this.nickname,
    required this.pokemonId,
    required this.pokemonType,
    this.level = 1,
    this.ability1 = "",
    this.ability2 = "",
    this.ability3 = "",
    this.ability4 = "",
    required this.trainerId,
    this.dateCaptured = '',
    this.attack = 100,
    this.health = 100,
});

  String pokemonName;
  String nickname;
  int pokemonId;
  String pokemonType;
  int level;
  String ability1;
  String ability2;
  String ability3;
  String ability4;
  int trainerId;
  String dateCaptured;
  int attack;
  int health;


}