import 'pokemon.dart';

final List<Pokemon> starterPokemonList = [
  // 14 Charmanders
  Pokemon(pokemonName: 'Charmander', nickname: 'Charmy', pokemonId: 1, pokemonType: 'Fire', trainerId: 1, level: 5, ability1: 'Ember', ability2: 'Scratch', ability3: 'Growl', ability4: 'Smokescreen', attack: 52, health: 39),
  Pokemon(pokemonName: 'Charmander', nickname: 'Blaze', pokemonId: 2, pokemonType: 'Fire', trainerId: 2, level: 8, ability1: 'Flamethrower', ability2: 'Dragon Breath', ability3: 'Slash', ability4: 'Fire Fang', attack: 60, health: 44),
  Pokemon(pokemonName: 'Charmander', nickname: 'Flare', pokemonId: 3, pokemonType: 'Fire', trainerId: 3, level: 12, ability1: 'Fire Spin', ability2: 'Metal Claw', ability3: 'Smokescreen', ability4: 'Growl', attack: 65, health: 48),
  Pokemon(pokemonName: 'Charmander', nickname: 'Inferno', pokemonId: 4, pokemonType: 'Fire', trainerId: 4, level: 15, ability1: 'Inferno', ability2: 'Scratch', ability3: 'Ember', ability4: 'Fire Fang', attack: 70, health: 52),
  Pokemon(pokemonName: 'Charmander', nickname: 'Cinder', pokemonId: 5, pokemonType: 'Fire', trainerId: 5, level: 7, ability1: 'Ember', ability2: 'Growl', ability3: 'Scratch', ability4: 'Smokescreen', attack: 54, health: 41),
  Pokemon(pokemonName: 'Charmander', nickname: 'Scorch', pokemonId: 6, pokemonType: 'Fire', trainerId: 6, level: 10, ability1: 'Fire Fang', ability2: 'Slash', ability3: 'Ember', ability4: 'Growl', attack: 62, health: 46),
  Pokemon(pokemonName: 'Charmander', nickname: 'Torch', pokemonId: 7, pokemonType: 'Fire', trainerId: 1, level: 6, ability1: 'Scratch', ability2: 'Growl', ability3: 'Ember', ability4: 'Smokescreen', attack: 53, health: 40),
  Pokemon(pokemonName: 'Charmander', nickname: 'Ember', pokemonId: 8, pokemonType: 'Fire', trainerId: 8, level: 9, ability1: 'Ember', ability2: 'Fire Spin', ability3: 'Growl', ability4: 'Scratch', attack: 58, health: 43),
  Pokemon(pokemonName: 'Charmander', nickname: 'Pyro', pokemonId: 9, pokemonType: 'Fire', trainerId: 9, level: 13, ability1: 'Flamethrower', ability2: 'Dragon Breath', ability3: 'Slash', ability4: 'Fire Fang', attack: 68, health: 50),
  Pokemon(pokemonName: 'Charmander', nickname: 'Ash', pokemonId: 10, pokemonType: 'Fire', trainerId: 10, level: 11, ability1: 'Fire Spin', ability2: 'Scratch', ability3: 'Growl', ability4: 'Ember', attack: 63, health: 47),
  Pokemon(pokemonName: 'Charmander', nickname: 'Sunny', pokemonId: 11, pokemonType: 'Fire', trainerId: 1, level: 14, ability1: 'Flamethrower', ability2: 'Fire Fang', ability3: 'Slash', ability4: 'Growl', attack: 69, health: 51),
  Pokemon(pokemonName: 'Charmander', nickname: 'Salamander', pokemonId: 12, pokemonType: 'Fire', trainerId: 12, level: 16, ability1: 'Inferno', ability2: 'Dragon Breath', ability3: 'Metal Claw', ability4: 'Ember', attack: 72, health: 54),
  Pokemon(pokemonName: 'Charmander', nickname: 'Flicker', pokemonId: 13, pokemonType: 'Fire', trainerId: 1, level: 4, ability1: 'Scratch', ability2: 'Growl', ability3: 'Ember', ability4: 'Smokescreen', attack: 51, health: 38),
  Pokemon(pokemonName: 'Charmander', nickname: 'Sparky', pokemonId: 14, pokemonType: 'Fire', trainerId: 14, level: 3, ability1: 'Growl', ability2: 'Scratch', ability3: 'Ember', ability4: 'Smokescreen', attack: 50, health: 37),

  // 13 Bulbasaurs
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Bulby', pokemonId: 15, pokemonType: 'Grass', trainerId: 15, level: 5, ability1: 'Tackle', ability2: 'Growl', ability3: 'Leech Seed', ability4: 'Vine Whip', attack: 49, health: 45),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Leafy', pokemonId: 16, pokemonType: 'Grass', trainerId: 16, level: 8, ability1: 'Razor Leaf', ability2: 'Sleep Powder', ability3: 'Tackle', ability4: 'Vine Whip', attack: 55, health: 50),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Sprout', pokemonId: 17, pokemonType: 'Grass', trainerId: 1, level: 12, ability1: 'Seed Bomb', ability2: 'Take Down', ability3: 'Leech Seed', ability4: 'Vine Whip', attack: 60, health: 54),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Vine', pokemonId: 18, pokemonType: 'Grass', trainerId: 18, level: 15, ability1: 'Vine Whip', ability2: 'Razor Leaf', ability3: 'Growl', ability4: 'Tackle', attack: 65, health: 58),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Seed', pokemonId: 19, pokemonType: 'Grass', trainerId: 19, level: 7, ability1: 'Tackle', ability2: 'Growl', ability3: 'Leech Seed', ability4: 'Vine Whip', attack: 51, health: 47),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Bud', pokemonId: 20, pokemonType: 'Grass', trainerId: 20, level: 10, ability1: 'Vine Whip', ability2: 'Sleep Powder', ability3: 'Tackle', ability4: 'Razor Leaf', attack: 56, health: 52),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Petal', pokemonId: 21, pokemonType: 'Grass', trainerId: 1, level: 6, ability1: 'Growl', ability2: 'Tackle', ability3: 'Leech Seed', ability4: 'Vine Whip', attack: 50, health: 46),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Root', pokemonId: 22, pokemonType: 'Grass', trainerId: 22, level: 9, ability1: 'Razor Leaf', ability2: 'Take Down', ability3: 'Tackle', ability4: 'Vine Whip', attack: 54, health: 51),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Bloom', pokemonId: 23, pokemonType: 'Grass', trainerId: 23, level: 13, ability1: 'Seed Bomb', ability2: 'Leech Seed', ability3: 'Vine Whip', ability4: 'Growl', attack: 61, health: 55),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Ivy', pokemonId: 24, pokemonType: 'Grass', trainerId: 1, level: 11, ability1: 'Vine Whip', ability2: 'Razor Leaf', ability3: 'Growl', ability4: 'Tackle', attack: 57, health: 53),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Fern', pokemonId: 25, pokemonType: 'Grass', trainerId: 25, level: 14, ability1: 'Seed Bomb', ability2: 'Take Down', ability3: 'Leech Seed', ability4: 'Vine Whip', attack: 63, health: 57),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Moss', pokemonId: 26, pokemonType: 'Grass', trainerId: 26, level: 16, ability1: 'Solar Beam', ability2: 'Razor Leaf', ability3: 'Growl', ability4: 'Tackle', attack: 67, health: 60),
  Pokemon(pokemonName: 'Bulbasaur', nickname: 'Thorn', pokemonId: 27, pokemonType: 'Grass', trainerId: 27, level: 4, ability1: 'Growl', ability2: 'Tackle', ability3: 'Leech Seed', ability4: 'Vine Whip', attack: 48, health: 44),

  // 13 Squirtles
  Pokemon(pokemonName: 'Squirtle', nickname: 'Squirt', pokemonId: 28, pokemonType: 'Water', trainerId: 28, level: 5, ability1: 'Tackle', ability2: 'Tail Whip', ability3: 'Water Gun', ability4: 'Withdraw', attack: 48, health: 44),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Shell', pokemonId: 29, pokemonType: 'Water', trainerId: 29, level: 8, ability1: 'Bubble', ability2: 'Rapid Spin', ability3: 'Tackle', ability4: 'Water Gun', attack: 54, health: 49),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Aqua', pokemonId: 30, pokemonType: 'Water', trainerId: 30, level: 12, ability1: 'Bite', ability2: 'Water Pulse', ability3: 'Withdraw', ability4: 'Water Gun', attack: 59, health: 53),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Bubble', pokemonId: 31, pokemonType: 'Water', trainerId: 1, level: 15, ability1: 'Bubble', ability2: 'Tackle', ability3: 'Tail Whip', ability4: 'Water Gun', attack: 64, health: 57),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Hydro', pokemonId: 32, pokemonType: 'Water', trainerId: 32, level: 7, ability1: 'Water Gun', ability2: 'Withdraw', ability3: 'Tackle', ability4: 'Tail Whip', attack: 50, health: 46),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Splash', pokemonId: 33, pokemonType: 'Water', trainerId: 1, level: 10, ability1: 'Water Pulse', ability2: 'Bite', ability3: 'Tackle', ability4: 'Water Gun', attack: 55, health: 51),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Wave', pokemonId: 34, pokemonType: 'Water', trainerId: 34, level: 6, ability1: 'Tail Whip', ability2: 'Tackle', ability3: 'Water Gun', ability4: 'Withdraw', attack: 49, health: 45),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Ripple', pokemonId: 35, pokemonType: 'Water', trainerId: 35, level: 9, ability1: 'Bubble', ability2: 'Rapid Spin', ability3: 'Tackle', ability4: 'Water Gun', attack: 53, health: 50),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Tide', pokemonId: 36, pokemonType: 'Water', trainerId: 36, level: 13, ability1: 'Bite', ability2: 'Water Pulse', ability3: 'Withdraw', ability4: 'Water Gun', attack: 60, health: 54),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Blue', pokemonId: 37, pokemonType: 'Water', trainerId: 37, level: 11, ability1: 'Water Gun', ability2: 'Tackle', ability3: 'Tail Whip', ability4: 'Withdraw', attack: 56, health: 52),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Jet', pokemonId: 38, pokemonType: 'Water', trainerId: 38, level: 14, ability1: 'Water Pulse', ability2: 'Bite', ability3: 'Tackle', ability4: 'Water Gun', attack: 62, health: 56),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Rain', pokemonId: 39, pokemonType: 'Water', trainerId: 1, level: 16, ability1: 'Hydro Pump', ability2: 'Aqua Tail', ability3: 'Bite', ability4: 'Water Gun', attack: 66, health: 59),
  Pokemon(pokemonName: 'Squirtle', nickname: 'Drizzle', pokemonId: 40, pokemonType: 'Water', trainerId: 1, level: 4, ability1: 'Tackle', ability2: 'Tail Whip', ability3: 'Water Gun', ability4: 'Withdraw', attack: 47, health: 43),
];

