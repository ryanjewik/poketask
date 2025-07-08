import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'about_page.dart';
import 'contact_page.dart';
import 'help_page.dart';

class MyScaffold extends StatelessWidget {
  final int selectedIndex;
  final Widget child;
  const MyScaffold({super.key, required this.selectedIndex, required this.child});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AboutPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyHomePage(title: 'Home')));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ContactPage()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HelpPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Poketask',
            style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 18,
                color: Colors.white)),
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (i) => _onItemTapped(context, i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_page),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Help',
          ),
        ],
        selectedItemColor: Color(0xFF90CAF9), // Light blue for both icon and text
        unselectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List <String> tasksToday = [
    'Task 1: Complete Flutter tutorial',
    'Task 2: Write blog post',
    'Task 3: Attend team meeting',
    'Task 4: Review pull requests',
    'Task 5: Plan next sprint'
  ];
  List<int> colorCodes = <int>[800, 700, 600, 500, 400];



  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      selectedIndex: 2,
      child: Container(
        //color: Color(0xFFCACACA), // Light grey background
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/zigzag_background.jpg'), // Replace with your image path
            fit: BoxFit.cover, // Adjusts how the image fits the container
          ),
        ),
        child: Center(
          child: Column(


            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('You have pushed the button this many times:'),
                    Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
                    FloatingActionButton(
                      onPressed: _incrementCounter,
                      tooltip: 'Increment',
                      child: const Icon(Icons.add),
                    ),
                    Container(
                      width: 200,
                      height: 200,
                      child: Image.asset(
                        'assets/sprites/squirtle.png', // Replace with your image path
                        fit: BoxFit.fill, // Adjusts how the image fits the container
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
                            thumbColor: MaterialStateProperty.all(Color(
                                0xFF95EEFA)),
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