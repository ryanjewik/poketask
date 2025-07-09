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
  List <String> tasksToday = [
    'Task 1: Complete Flutter tutorial',
    'Task 2: Write blog post',
    'Task 3: Attend team meeting',
    'Task 4: Review pull requests',
    'Task 5: Plan next sprint'
  ];
  List<int> colorCodes = <int>[800, 700, 600, 500, 400];

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
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: MyScaffold(
        selectedIndex: 2,
        child: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PokemonPage()),
                        );
                      },
                      child: ScaleTransition(
                        scale: _animation ?? AlwaysStoppedAnimation(1.0),
                        child: Container(
                          width: 300,
                          height: 300,
                          child: Image.asset(
                            'assets/sprites/squirtle.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    )
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
                            thumbColor: MaterialStateProperty.all(Color(0xFF95EEFA)),
                            trackColor: MaterialStateProperty.all(Colors.transparent),
                          ),
                        ),
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
                                  color: Colors.red[colorCodes[index]],
                                  child: Center(child: Text('Entry ${tasksToday[index]}')),
                                );
                              },
                            ),
                          ),
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
    );
  }
}
