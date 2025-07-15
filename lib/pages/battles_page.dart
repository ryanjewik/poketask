import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../models/pokemon_list.dart';
import '../models/trainer.dart';
import 'homepage.dart';
import '../services/my_scaffold.dart';
import '../models/trainer_list.dart';

class BattlesPage extends StatefulWidget {
  const BattlesPage({super.key});

  @override
  State<BattlesPage> createState() => _BattlesPageState();
}

class _BattlesPageState extends State<BattlesPage> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _slideAnimations;
  bool showByTasks = true;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(5, (i) => AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200 + i * 60),
    ));
    _slideAnimations = List.generate(5, (i) => Tween<Offset>(
      begin: Offset(-1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllers[i],
      curve: Curves.easeOutBack,
    )));
    // Staggered animation
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 80 * i), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the first trainer
    final trainer = trainerList.isNotEmpty ? trainerList[0] : null;
    // Get all Pokémon for the first trainer's slots (by matching pokemonId)
    List<Pokemon> trainerPokemons = [];
    if (trainer != null) {
      final slotIds = [
        trainer.pokemonSlot1,
        trainer.pokemonSlot2,
        trainer.pokemonSlot3,
        trainer.pokemonSlot4,
        trainer.pokemonSlot5,
        trainer.pokemonSlot6,
      ];
      trainerPokemons = starterPokemonList.where((poke) => slotIds.contains(poke.pokemonId)).toList();
    }
    // Get top 5 trainers by completedTasks or wins
    List<Trainer> sortedTrainers = List<Trainer>.from(trainerList);
    if (showByTasks) {
      sortedTrainers.sort((a, b) => b.completedTasks.compareTo(a.completedTasks));
    } else {
      sortedTrainers.sort((a, b) => b.wins.compareTo(a.wins));
    }
    final top5 = sortedTrainers.take(5).toList();
    return Container(
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/background/gym-background.jpg',
                fit: BoxFit.fill,
              ),
            ),
          ),
          MyScaffold(
          selectedIndex: 4,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: trainer == null
                    ? Center(child: Text('No trainer found', style: TextStyle(color: Colors.white)))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            trainer.trainerName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  blurRadius: 6,
                                  color: Colors.black.withOpacity(0.7),
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Level: ${trainer.level}   Tasks Completed: ${trainer.completedTasks}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Wins: ${trainer.wins}   Losses: ${trainer.losses}',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.lightGreenAccent,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(height: 2),
                          Wrap(
                            spacing: 12,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                  child: GridView.count(
                                    crossAxisCount: 2, // 2 columns
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    childAspectRatio: 2.5, // Decrease aspect ratio for taller tiles
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    children: trainerPokemons.map((poke) => GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: Colors.grey[900],
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(24),
                                              side: BorderSide(color: Colors.amber, width: 3),
                                            ),
                                            title: Row(
                                              children: [
                                                Image.asset(
                                                  'assets/sprites/${poke.pokemonName.toLowerCase()}.png',
                                                  width: 48,
                                                  height: 48,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  poke.nickname,
                                                  style: TextStyle(fontSize: 20, color: Colors.amber, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Type: ${poke.pokemonType}', style: TextStyle(color: Colors.white)),
                                                Text('Level: ${poke.level}', style: TextStyle(color: Colors.white)),
                                                Text('Attack: ${poke.attack}', style: TextStyle(color: Colors.white)),
                                                Text('Health: ${poke.health}', style: TextStyle(color: Colors.white)),
                                                SizedBox(height: 8),
                                                Text('Moves:', style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
                                                Text('1. ${poke.ability1}', style: TextStyle(color: Colors.white)),
                                                Text('2. ${poke.ability2}', style: TextStyle(color: Colors.white)),
                                                Text('3. ${poke.ability3}', style: TextStyle(color: Colors.white)),
                                                Text('4. ${poke.ability4}', style: TextStyle(color: Colors.white)),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: Text('Close', style: TextStyle(color: Colors.redAccent)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(2),
                                        height: 70, // Reduced vertical size
                                        constraints: BoxConstraints(minHeight: 50, maxHeight: 70), // Reduced min/max height
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white, width: 2),
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.black.withAlpha(20),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Reduced vertical padding
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(width: 12), // Shift content to the right
                                            Image.asset(
                                              'assets/sprites/${poke.pokemonName.toLowerCase()}.png',
                                              width: 36,
                                              height: 36,
                                            ),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(poke.nickname, style: TextStyle(fontSize: 14, color: Colors.white), overflow: TextOverflow.ellipsis),
                                                  SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text('Lv. ${poke.level}', style: TextStyle(fontSize: 12, color: Colors.white)),
                                                      SizedBox(width: 8),
                                                      Text(poke.pokemonType, style: TextStyle(fontSize: 12, color: Colors.white)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 4), // Increased padding above the button
                            child: SizedBox(
                              width: 220,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 6,
                                  textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/pokebattle');
                                },
                                child: Text('BATTLE', style: TextStyle(letterSpacing: 2)),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              Divider(
                thickness: 4,
                color: Colors.amber,
              ),
              Text(
                'Top 5 Trainers by ' + (showByTasks ? 'Completed Tasks' : 'Total Wins'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  fontSize: 20,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black.withAlpha(70),
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: Colors.amber,
                  color: Colors.amber,
                  isSelected: [showByTasks, !showByTasks],
                  onPressed: (int idx) {
                    setState(() {
                      showByTasks = idx == 0;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('By Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('By Wins', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: ListView.separated(
                  itemCount: top5.length,
                  separatorBuilder: (context, index) => SizedBox.shrink(),
                  itemBuilder: (context, index) {
                    final t = top5[index];
                    return SlideTransition(
                      position: _slideAnimations.length > index ? _slideAnimations[index] : AlwaysStoppedAnimation(Offset.zero),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                        decoration: BoxDecoration(
                          color: index == 0 ? Colors.amber.withAlpha(80) : Colors.black.withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber, width: index == 0 ? 2 : 1),
                          boxShadow: [
                            if (index == 0)
                              BoxShadow(
                                color: Colors.amber.withAlpha(60),
                                blurRadius: 6,
                                offset: Offset(0, 1),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: index == 0 ? Colors.amber : Colors.grey[800],
                              radius: 13,
                              child: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: index == 0 ? Colors.deepOrange : Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.trainerName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 17,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                                  SizedBox(width: 2),
                                  Text(
                                    'Tasks: ${t.completedTasks}',
                                    style: TextStyle(
                                      color: Colors.lightGreenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index == 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: Icon(Icons.star, color: Colors.amber, size: 16),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),]
    ),
    );
  }
}
