import 'package:flutter/material.dart';
import '../services/my_scaffold.dart';
import 'homepage.dart';
import '../models/pokemon.dart';
import '../models/trainer.dart';

class PokedexPage extends StatefulWidget {
  const PokedexPage({super.key});



  @override
  State<PokedexPage> createState() => _PokedexPageState();
}


class _PokedexPageState extends State<PokedexPage> {

  // Example Pokemon object
  final Pokemon pokemon = Pokemon(
    nickname: 'Squirtle Squad',
    level: 10,
    pokemonType: 'Water',
    pokemonId: 1,
    trainerId: 1,
    pokemonName: 'squirtle',
    health: 100,
    attack: 100,
    ability1: "hydro pump",
    ability2: "shell bash",
    ability3: "shell shield",
    ability4: "water gun",
  );

  // Example Trainer object
  final Trainer trainer = Trainer(
      trainerName: 'Ash Ketchum',
      trainerId: 1,
      pokemonCount: 1,
      dateJoined: '2023-10-01',
      level: 5,
      sex: 'male'
  );


  @override
  Widget build(BuildContext context) {
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
                                      "assets/sprites/squirtle.png",
                                      color: Colors.black.withAlpha(250),
                                      colorBlendMode: BlendMode.srcATop,
                                      width: 200, // adjust as needed
                                      height: 200, // adjust as needed
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                  // Main image
                                  Image.asset(
                                    "assets/sprites/${pokemon.pokemonName}.png",
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
                                        pokemon.nickname,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 2),
                                      Text('Level: ${pokemon.level}', style: TextStyle(fontSize: 15)),
                                      SizedBox(height: 2),
                                      Text('Type: ${pokemon.pokemonType}', style: TextStyle(fontSize: 15)),
                                      SizedBox(height: 2),
                                      Text('Attack: ${pokemon.attack}', style: TextStyle(fontSize: 15)),
                                      SizedBox(height: 2),
                                      Text('Health: ${pokemon.health}', style: TextStyle(fontSize: 15)),
                                      SizedBox(height: 2),
                                      Text('Ability 1: ${pokemon.ability1}', style: TextStyle(fontSize: 15)),
                                      SizedBox(height: 2),
                                      Text('Ability 2: ${pokemon.ability2}', style: TextStyle(fontSize: 15)),
                                      SizedBox(height: 2),
                                      Text('Ability 3: ${pokemon.ability3}', style: TextStyle(fontSize: 15)),
                                      SizedBox(height: 2),
                                      Text('Ability 4: ${pokemon.ability4}', style: TextStyle(fontSize: 15)),
                                    ],
                                  ),
                                ))
                          ]
                        )
                      ),
                      Expanded(//pokemon selection
                        flex: 3,
                        child: Container(
                          color: Colors.teal,
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
