import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StatefulWithIconPage(),
    );
  }
}

class StatefulWithIconPage extends StatefulWidget {
  const StatefulWithIconPage({super.key});

  @override
  State<StatefulWithIconPage> createState() => _StatefulWithIconPageState();
}

class _StatefulWithIconPageState extends State<StatefulWithIconPage> {
  // Counter state variable
  int _counter = 0;

  // Function to increment the counter
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateful Widget Example'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Graduation cap icon
            const Icon(
              Icons.school,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 10),
            // Counter display
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // CHANGED: Replaced GestureDetector text with a proper ElevatedButton
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button background color
                foregroundColor: Colors.white, // Text color inside button
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Slightly rounded corners
                ),
              ),
              onPressed: _incrementCounter,
              child: const Text(
                'Click me',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
