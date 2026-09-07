import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animation Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const AnimationPage(),
    );
  }
}

class AnimationPage extends StatefulWidget {
  const AnimationPage({super.key});

  @override
  State<AnimationPage> createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  bool _expanded = false;
  bool _visible = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _rotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void rotate() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Animation Demo'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FADE ANIMATION
            const Text(
              '1. Fade Animation',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Hello Flutter!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _visible = !_visible;
                });
              },
              child: Text(
                _visible ? 'Fade Out' : 'Fade In',
              ),
            ),

            const SizedBox(height: 40),

            // ANIMATED CONTAINER
            const Text(
              '2. Animated Container',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              width: _expanded ? 300 : 150,
              height: _expanded ? 180 : 100,
              decoration: BoxDecoration(
                color: _expanded ? Colors.orange : Colors.blue,
                borderRadius: BorderRadius.circular(
                  _expanded ? 30 : 10,
                ),
              ),
              child: const Center(
                child: Text(
                  'Animated Box',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Text(
                _expanded ? 'Shrink' : 'Expand',
              ),
            ),

            const SizedBox(height: 40),

            // ROTATION ANIMATION
            const Text(
              '3. Rotation Animation',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            AnimatedBuilder(
              animation: _rotation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotation.value * 6.283185,
                  child: child,
                );
              },
              child: const Icon(
                Icons.settings,
                size: 100,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: rotate,
              child: const Text('Rotate'),
            ),

            const SizedBox(height: 40),

            // SCALE ANIMATION
            const Text(
              '4. Scale Animation',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.7,
                end: 1.0,
              ),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 220,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Scale Animation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
