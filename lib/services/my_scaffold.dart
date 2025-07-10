import 'package:flutter/material.dart';
import '../pages/pokedex.dart';
import '../pages/calendar.dart';
import '../pages/taskspage.dart';
import '../pages/battles_page.dart';
import '../pages/homepage.dart';

//shape to draw pokedex header
class PokedexClipper extends CustomClipper<Path> {
  /// % of the width that remains flat on the *left* bottom
  static const double _bottomFlatLeftFrac = 0.4;   // 1/5 of the width
  /// x-coordinate (as % of width) where the diagonal stops and
  /// the bottom becomes flat again on the right
  static const double _bottomFlatRightStartFrac = 0.6; // 4/5 of width
  /// How deep the right side goes (0 = top, 1 = full height)
  static const double _rightDepthFrac = 0.60;       // shorter than the left
  static const double _curveRadius = 1.0;           // curve radius at bends

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;

    final double leftFlatX = w * _bottomFlatLeftFrac;
    final double rightFlatX = w * _bottomFlatRightStartFrac;
    final double rightY = h * _rightDepthFrac;

    final path = Path();

    // ── 1. Top edge ──
    path.moveTo(0, 0);
    path.lineTo(w, 0);

    // ── 2. Right vertical edge ──
    path.lineTo(w, rightY - _curveRadius);

    // ── 3. Curve from right vertical to bottom-right flat ──
    path.quadraticBezierTo(
        w, rightY,                 // control point
        w - _curveRadius, rightY  // endpoint
    );

    // ── 4. Bottom-right flat section ──
    path.lineTo(rightFlatX + _curveRadius, rightY);

    // ── 5. Curve from flat into diagonal ──
    path.quadraticBezierTo(
        rightFlatX, rightY,                  // control
        rightFlatX - _curveRadius, rightY + _curveRadius // end of curve
    );

    // ── 6. Diagonal down to left flat ──
    path.lineTo(leftFlatX + _curveRadius, h - _curveRadius);

    // ── 7. Curve into bottom-left flat ──
    path.quadraticBezierTo(
        leftFlatX, h,                         // control
        leftFlatX - _curveRadius, h           // end of curve
    );

    // ── 8. Bottom-left flat section ──
    path.lineTo(0, h);

    // ── 9. Left vertical edge ──
    path.lineTo(0, 0);

    path.close();
    return path;
  }


  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}





class MyScaffold extends StatefulWidget implements PreferredSizeWidget{
  final int selectedIndex;
  final Widget child;

  const MyScaffold({
    super.key,
    required this.selectedIndex,
    required this.child,
    this.height = 120
  });

  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Loops the animation

    _pulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Black border using CustomPaint (not clipped)
            CustomPaint(
              painter: _PokedexBorderPainter(),
              size: const Size.fromHeight(80),
            ),
            // Main AppBar clipped to Pokedex shape
            ClipPath(
              clipper: PokedexClipper(),
              child: AppBar(
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                backgroundColor: Theme.of(context).colorScheme.primary,
                title: null,
                centerTitle: false,
                flexibleSpace: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 24, right: 10),
                    child: Stack(
                      children: [
                        // Stroke
                        Text(
                          'Poketask',
                          style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 14,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = Colors.black,
                          ),
                        ),
                        // Fill
                        Text(
                          'Poketask',
                          style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Blue glowing circular light on the top left (now on top of everything)
            Positioned(
              left: 25,
              top: 25,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blueAccent.withValues(alpha: 0.9),
                      Colors.blueAccent.withValues(alpha: .5),
                      Colors.transparent,
                    ],
                    stops: [0.4, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.7),
                      blurRadius: 36,
                      spreadRadius: 16,
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
            // Red, yellow, green Pokédex lights
            Positioned(
              left: 95,
              top: 35,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.redAccent.withValues(alpha: 0.9),
                      Colors.redAccent.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                    stops: [0.5, 0.8, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.7),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Positioned(
              left: 125,
              top: 35,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.yellowAccent.withValues(alpha: 0.9),
                      Colors.yellowAccent.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                    stops: [0.5, 0.8, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellowAccent.withValues(alpha: 0.7),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Positioned(
              left: 155,
              top: 35,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.greenAccent.withValues(alpha: 0.9),
                      Colors.greenAccent.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                    stops: [0.5, 0.8, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withValues(alpha: 0.7),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black, width: 3),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          type: BottomNavigationBarType.fixed,
          currentIndex: widget.selectedIndex,
          onTap: (i) => _onItemTapped(context, i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.earbuds_rounded), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.catching_pokemon), label: 'Pokedex'),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Battle'),
          ],
          selectedItemColor: Color(0xFF90CAF9),
          unselectedItemColor: Colors.white,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == widget.selectedIndex) return;
    Widget page;
    switch (index) {
      case 0:
        page = CalendarPage();
        break;
      case 1:
        page = TasksPage();
        break;
      case 2:
        page = MyHomePage(title: 'Poketask');
        break;
      case 3:
        page = PokedexPage();
        break;
      case 4:
        page = BattlesPage();
        break;
      default:
        page = MyHomePage(title: 'Poketask');
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}


//draws black border around the pokedex shape
class _PokedexBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = PokedexClipper().getClip(size);
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
