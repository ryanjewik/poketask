import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/my_scaffold.dart';
import '../models/pokemon.dart';
import '../models/trainer.dart';

class favPokemonPage extends StatefulWidget {
  final String trainerId;
  const favPokemonPage({Key? key, required this.trainerId}) : super(key: key);

  @override
  State<favPokemonPage> createState() => _favPokemonPageState();
}

class _favPokemonPageState extends State<favPokemonPage> {
  Trainer? trainer;
  List<Pokemon> trainerPokemon = [];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchTrainerAndPokemon();
  }

  Future<void> fetchTrainerAndPokemon() async {
    // Fetch trainer
    final trainerRes = await supabase
        .from('trainer_table')
        .select()
        .eq('trainer_id', widget.trainerId)
        .limit(1)
        .single();
    setState(() {
      trainer = Trainer.fromJson(trainerRes);
    });
    // Fetch Pokémon for this trainer
    final pokemonRes = await supabase
        .from('pokemon_table')
        .select()
        .eq('trainer_id', widget.trainerId);
    setState(() {
      trainerPokemon = List<Pokemon>.from(
        pokemonRes.map((item) => Pokemon.fromJson(item)),
      );
    });
  }

  Future<void> setFavoritePokemon(String pokemonId) async {
    if (trainer == null) return;
    await supabase
        .from('trainer_table')
        .update({'favorite_pokemon': pokemonId})
        .eq('trainer_id', widget.trainerId);
    setState(() {
      trainer!.favoritePokemon = pokemonId;
    });
    // Notify homepage to refresh after favorite change
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Pokémon', style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.red[600],
        elevation: 6,
        shadowColor: Colors.yellow[700],
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/grid_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Select your favorite Pokémon:', style: TextStyle(fontSize: 20, fontFamily: 'Fredoka', color: Colors.yellow[800], fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.red, blurRadius: 2, offset: Offset(1,1))])),
              SizedBox(height: 16),
              Expanded(
                child: trainerPokemon.isEmpty
                  ? Text('No Pokémon found for this trainer.', style: TextStyle(color: Colors.red))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: trainerPokemon.length,
                      itemBuilder: (context, idx) {
                        final poke = trainerPokemon[idx];
                        final isFavorite = trainer?.favoritePokemon == poke.pokemonId;
                        return GestureDetector(
                          onTap: () async {
                            await setFavoritePokemon(poke.pokemonId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${poke.nickname} is now your favorite!')),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isFavorite ? Colors.amber : Colors.blue[300]!,
                                width: isFavorite ? 4 : 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: isFavorite ? Colors.yellow[100] : Colors.white.withOpacity(0.85),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: Offset(2, 4),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/sprites/${poke.pokemonName.toLowerCase()}.png',
                                  width: 64,
                                  height: 64,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isFavorite)
                                      Icon(Icons.star, color: Colors.amber, size: 20, shadows: [Shadow(color: Colors.red, blurRadius: 2)]),
                                    Text(poke.nickname, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Fredoka', color: Colors.blue[900])),
                                  ],
                                ),
                                Text('Lv. ${poke.level}', style: TextStyle(fontSize: 12, fontFamily: 'Fredoka', color: Colors.grey[800])),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
