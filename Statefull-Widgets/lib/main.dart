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
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Header
                const Text(
                  'Layouts',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // ROW WIDGET SECTION
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Row Widget',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Row with evenly spaced icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(Icons.home, size: 30),
                          Icon(Icons.star, size: 30),
                          Icon(Icons.person, size: 30),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // STACK WIDGET SECTION
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Stack Widget',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Stack overlapping containers
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base large blue container
                          Container(
                            width: 120,
                            height: 120,
                            color: Colors.blue,
                          ),
                          // Overlapping small orange container
                          Container(
                            width: 60,
                            height: 60,
                            color: Colors.deepOrange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
