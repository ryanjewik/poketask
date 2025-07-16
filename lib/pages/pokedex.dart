import 'package:flutter/material.dart';
import '../services/my_scaffold.dart';
import 'homepage.dart';
import '../models/pokemon.dart';
import '../models/trainer.dart';
import '../models/pokemon_list.dart';

class PokedexPage extends StatefulWidget {
  const PokedexPage({super.key});



  @override
  State<PokedexPage> createState() => _PokedexPageState();
}


class _PokedexPageState extends State<PokedexPage> {

  // Example Pokemon object
  final Pokemon pokemon = Pokemon(
    pokemonId: '1',
    dateCaught: DateTime.now(),
    pokemonName: 'Squirtle',
    nickname: 'Squirtle Squad',
    type: 'Water',
    level: 10,
    experiencePoints: 100,
    trainerId: '1',
    health: 100,
    attack: 100,
    ability1: "hydro pump",
    ability2: "shell bash",
    ability3: "shell shield",
    ability4: "water gun",
  );

  // Example Trainer object
  final Trainer trainer = Trainer(
    trainerId: '1',
    createdAt: DateTime.now(),
    sex: 'male',
    username: 'Ash Ketchum',
    wins: 0,
    losses: 0,
    experiencePoints: 0,
    level: 5,
    pokemonSlot1: '',
    pokemonSlot2: '',
    pokemonSlot3: '',
    pokemonSlot4: '',
    pokemonSlot5: '',
    pokemonSlot6: '',
    favoritePokemon: '',
    completedTasks: 0,
  );

  Pokemon? selectedPokemon;

  @override
  Widget build(BuildContext context) {
    final Pokemon displayPokemon = selectedPokemon ?? pokemon;
    return Container(
      color: Colors.white,
      child: Stack(
          children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset('assets/background/mobile_grid_background_2.jpg',
              fit: BoxFit.fill,
              )
            )
          ),
            MyScaffold(
              selectedIndex: 3,
              trainerId: trainer.trainerId,
              child: Center(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(//pokemon
                              flex: 1,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Shadow image
                                  Positioned(
                                    left: -6,
                                    top: 5.0,
                                    child: Image.asset(
                                      "assets/sprites/${displayPokemon.pokemonName.toLowerCase()}.png",
                                      color: Colors.black.withAlpha(250),
                                      colorBlendMode: BlendMode.srcATop,
                                      width: 200, // adjust as needed
                                      height: 200, // adjust as needed
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                  // Main image
                                  Image.asset(
                                    "assets/sprites/${displayPokemon.pokemonName.toLowerCase()}.png",
                                    width: 200, // match shadow size
                                    height: 200,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ],
                              )
                            ),
                            Expanded(//pokemon stats
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0x9ECACACA), // Light grey background
                                    border: Border.all(color: Colors.redAccent, width: 3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayPokemon.nickname,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 2),
                                      Text('Level: ${displayPokemon.level}', style: TextStyle(fontSize: 13)),
                                      SizedBox(height: 2),
                                      Text('Type: ${displayPokemon.type}', style: TextStyle(fontSize: 13)),
                                      SizedBox(height: 2),
                                      Text('Attack: ${displayPokemon.attack}', style: TextStyle(fontSize: 13)),
                                      SizedBox(height: 2),
                                      Text('Health: ${displayPokemon.health}', style: TextStyle(fontSize: 13)),
                                      SizedBox(height: 2),
                                      Text('Ability 1: ${displayPokemon.ability1}', style: TextStyle(fontSize: 13)),
                                      SizedBox(height: 2),
                                      Text('Ability 2: ${displayPokemon.ability2}', style: TextStyle(fontSize: 13)),
                                      SizedBox(height: 2),
                                      Text('Ability 3: ${displayPokemon.ability3}', style: TextStyle(fontSize: 13)),
                                      SizedBox(height: 2),
                                      Text('Ability 4: ${displayPokemon.ability4}', style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ))
                          ]
                        )
                      ),
                      Expanded(//pokemon selection
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0x9ECACACA), // Light grey background
                            border: Border.all(color: Colors.redAccent, width: 3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: GridView.count(
                              // Create a grid with 2 columns.
                              // If you change the scrollDirection to horizontal,
                              // this produces 2 rows.
                              crossAxisCount: 4,
                              // Generate 100 widgets that display their index in the list.
                              children: starterPokemonList.map((pokemon) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedPokemon = pokemon;
                                    });
                                  },
                                  child: SizedBox(
                                    width: 80, // Limit the width of each grid item
                                    height: 100, // Limit the height of each grid item
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 50, // Limit image area
                                          height: 50,
                                          child: Image.asset(
                                            'assets/sprites/${pokemon.pokemonName.toLowerCase()}.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        SizedBox(
                                          width: 60, // Limit text area width
                                          child: Text(
                                            pokemon.nickname,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      )
                    ],
                  )
              )
            )
          ]
        ),
    );
  }
}
