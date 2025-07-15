import 'package:flutter/material.dart';
import 'package:poketask/pages/fav_pokemon.dart';
import '../models/task.dart';
import '../models/trainer_list.dart';
import '../services/my_scaffold.dart';
import '../services/task_details_card.dart';
import '../models/pokemon.dart';
import '../models/trainer.dart';
import '../models/pokemon_list.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  List<int> colorCodes = <int>[400, 500, 600, 700, 800];


  // Example Pokemon object
  final Pokemon pokemon = Pokemon(
    nickname: 'Squirtle Squad',
    level: 10,
    pokemonType: 'Water',
    pokemonId: 1,
    trainerId: 1,
    pokemonName: 'squirtle',
  );

  // Remove the local Trainer instance and use the global trainerList
  Trainer get trainer => trainerList.firstWhere((t) => t.trainerId == 1);

  final List<Task> tasksToday = [
    Task(
      eventName: 'Discuss project requirements',
      from: DateTime.now().subtract(Duration(hours: 2)),
      to: DateTime.now().subtract(Duration(hours: 1)),
      notes: 'Go over the main features and deadlines.',
      threadId: 1,
      folderId: 1,
    ),
    Task(
      eventName: 'Review code',
      from: DateTime.now().add(Duration(hours: 2)),
      to: DateTime.now().add(Duration(hours: 3)),
      notes: 'Check the latest PRs and leave comments.',
      threadId: 1,
      isCompleted: true,
      folderId: 2,
    ),
    Task(
      eventName: 'Write documentation',
      from: DateTime.now().add(Duration(hours: 4)),
      to: DateTime.now().add(Duration(hours: 5)),
      notes: 'Document the new API endpoints.',
      threadId: 1,
      folderId: 2,
    ),
    Task(
      eventName: 'Team meeting',
      from: DateTime.now().add(Duration(hours: 6)),
      to: DateTime.now().add(Duration(hours: 7)),
      notes: 'Weekly sync with the whole team.',
      threadId: 2,
      folderId: 3,
      highPriority: true,
    ),
    Task(
      eventName: 'design battle system',
      from: DateTime.now().subtract(Duration(hours: 2)),
      to: DateTime.now().subtract(Duration(hours: 1)),
      notes: 'how will the min max AI work',
      threadId: 1,
    ),
  ];


  AnimationController? _controller;
  Animation<double>? _animation;



  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.easeOutBack);
    _controller?.forward();

    //I think the code we need to retrieve pokemon, task, and trainer info needs to go here


  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Pokemon? get favoritedPokemon {
    final favId = trainer.favoritePokemon;
    try {
      return starterPokemonList.firstWhere((p) => p.pokemonId == favId && p.trainerId == trainer.trainerId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter tasksToday for only today's tasks
    final today = DateTime.now();
    final List<Task> onlyTodayTasks = tasksToday.where((task) =>
      task.from.year == today.year &&
      task.from.month == today.month &&
      task.from.day == today.day
    ).toList();

    final Pokemon? pokemon = favoritedPokemon ?? (() {
      try {
        return starterPokemonList.firstWhere((p) => p.pokemonId == trainer.pokemonSlot1);
      } catch (e) {
        return null;
      }
    })();

    return Stack(
      children: [
        // Add zigzag background only on the homepage
        Positioned.fill(
          child: Image.asset(
            'assets/background/zigzag_background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        MyScaffold(
          selectedIndex: 2,
          child: Center(
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 32),
                      Transform.translate(
                        offset: Offset(0, -20),
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => favPokemonPage()),
                            );
                            setState(() {}); // Refresh after returning from fav page
                          },
                          child: ScaleTransition(
                            scale: _animation ?? AlwaysStoppedAnimation(1.0),
                            child: SizedBox(
                              width: 250,
                              height: 250,
                              child: pokemon != null ? Image.asset(
                                'assets/sprites/${pokemon.pokemonName.toLowerCase()}.png',
                                fit: BoxFit.fill,
                              ) : SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, 0),
                        child: Column(
                          children: [
                            Text(
                              pokemon?.nickname ?? '',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              pokemon != null ? 'Level: ${pokemon.level}' : '',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
                      child: SizedBox(
                        height: 200,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            scrollbarTheme: ScrollbarThemeData(
                              thumbColor: WidgetStateProperty.all(Color(0xFF95EEFA)),
                              trackColor: WidgetStateProperty.all(Colors.transparent),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  "Today's tasks",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  interactive: true,
                                  radius: Radius.circular(8),
                                  thickness: 4,
                                  scrollbarOrientation: ScrollbarOrientation.right,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListView.builder(
                                      itemCount: onlyTodayTasks.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final task = onlyTodayTasks[index];
                                        return GestureDetector(
                                          onTap: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (context) => TaskDetailsCard(task: task),
                                            );
                                          },
                                          child: Container(
                                            height: 50,
                                            color: Colors.red[colorCodes[index % colorCodes.length]] ?? Colors.red[800],
                                            child: Center(child: Text(task.eventName)),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: 70, // negative value to bleed above the AppBar
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trainer.trainerName,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(1,1))],
                ),
              ),
              Text(
                'Level: ${trainer.level}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(1,1))],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
