import 'package:flutter/material.dart';
import 'package:poketask/pages/pokemon.dart';
import '../services/my_scaffold.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  //task stuff
  List <String> tasksToday = [
    'Task 1: Complete Flutter tutorial',
    'Task 2: Write blog post',
    'Task 3: Attend team meeting',
    'Task 4: Review pull requests',
    'Task 5: Plan next sprint'
    'Task 6: Build the calendar page'
  ];
  List<int> colorCodes = <int>[400, 500, 600, 700, 800];

  //pokemon stuff
  final String pokemonNickname = 'Squirtle Squad';
  final int pokemonLevel = 10;

  //trainer stuff
  final String trainerName = 'Ash Ketchum';
  final int trainerLevel = 5;



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

  @override
  Widget build(BuildContext context) {
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
                        offset: Offset(0, -20), // Shift Squirtle image up by 50 pixels
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PokemonPage()),
                            );
                          },
                          child: ScaleTransition(
                            scale: _animation ?? AlwaysStoppedAnimation(1.0),
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: Image.asset(
                                'assets/sprites/squirtle.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -35),
                        child: Column(
                          children: [
                            Text(
                              pokemonNickname,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Level: $pokemonLevel',
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
                                      itemCount: tasksToday.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Container(
                                          height: 50,
                                          color: Colors.red[colorCodes[index]] ?? Colors.red[800],
                                          child: Center(child: Text('Entry ${tasksToday[index]}')),
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
                '$trainerName',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(1,1))],
                ),
              ),
              Text(
                'Level: $trainerLevel',
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
