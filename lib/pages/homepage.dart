import 'package:flutter/material.dart';
import 'package:poketask/pages/fav_pokemon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../services/my_scaffold.dart';
import '../services/task_details_card.dart';
import '../models/pokemon.dart';
import '../models/trainer.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.trainerId});
  final String title;
  final String trainerId;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {


  List<int> colorCodes = <int>[400, 500, 600, 700, 800];




  // Remove the local Trainer instance and use the global trainerList

  // State variables to hold fetched data
  Trainer? trainer;
  List<Pokemon> pokemonList = [];
  List<Task> tasks = [];

  late final String trainerId;



  AnimationController? _controller;
  Animation<double>? _animation;



  @override
  void initState() {
    super.initState();
    trainerId = widget.trainerId;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.easeOutBack);
    _controller?.forward();

    fetchTrainerData();
    fetchPokemonData();
    fetchTaskData();
  }

  Future<void> fetchTrainerData() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('trainer_table')
          .select()
          .eq('trainer_id', trainerId)
          .limit(1)
          .single();
      if (response != null) {
        if (!mounted) return;
        setState(() {
          trainer = Trainer.fromJson(response);
        });
      }

    } catch (e) {
      debugPrint('❌ Failed to fetch trainer data: \\${e}');
    }
  }

  Future<void> fetchPokemonData() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('pokemon_table')
          .select()
          .eq('trainer_id', trainerId);
      if (response != null) {
        if (!mounted) return;
        setState(() {
          pokemonList = List<Pokemon>.from(
            response.map((item) => Pokemon.fromJson(item)),
          );
        });
      }
      //debugPrint('✅ Pokemon data: \\${response}');
    } catch (e) {
      debugPrint('❌ Failed to fetch pokemon data: \\${e}');
    }
  }

  Future<void> fetchTaskData() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('task_table')
          .select()
          .eq('trainer_id', trainerId);
      if (response != null) {
        if (!mounted) return;
        setState(() {
          tasks = List<Task>.from(
            response.map((item) => Task.fromJson(item)),
          );
        });
      }
      //debugPrint('✅ Task data: \\${response}');
    } catch (e) {
      debugPrint('❌ Failed to fetch task data: \\${e}');
    }
  }

  Pokemon? get favoritedPokemon {
    if (trainer == null) return null;
    final favId = trainer!.favoritePokemon;
    try {
      // Only match pokemonId, not trainerId
      return pokemonList.firstWhere((p) => p.pokemonId == favId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter tasks for only today's tasks
    final today = DateTime.now();
    final List<Task> onlyTodayTasks = tasks.where((task) =>
      task.startDate.year == today.year &&
      task.startDate.month == today.month &&
      task.startDate.day == today.day
    ).toList();

    final Pokemon? pokemon = favoritedPokemon ?? (() {
      if (trainer == null) return null;
      try {
        return pokemonList.firstWhere((p) => p.pokemonId == trainer!.pokemonSlot1);
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
          trainerId: trainerId,
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
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => favPokemonPage(trainerId: trainerId)),
                            );
                            if (result == true) {
                              await fetchTrainerData();
                              await fetchPokemonData();
                              setState(() {});
                            }
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
                                            final result = await showDialog(
                                              context: context,
                                              builder: (context) => TaskDetailsCard(task: task),
                                            );
                                            if (result == 'delete') {
                                              // Optionally handle delete
                                            }
                                            await fetchTaskData();
                                            setState(() {});
                                          },
                                          child: Container(
                                            height: 50,
                                            color: Colors.red[colorCodes[index % colorCodes.length]] ?? Colors.red[800],
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(task.eventName),
                                                if (task.isCompleted)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                                                  ),
                                              ],
                                            ),
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
                trainer?.username ?? '',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(1,1))],
                ),
              ),
              Text(
                'Level: ${trainer?.level ?? ''}',
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
