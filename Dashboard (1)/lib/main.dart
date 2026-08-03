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
      title: "Student Dashboard",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StudentDashboard(),
    );
  }
}

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool notifications = false;
  int counter = 0;

  Widget featureItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 35,
          ),
        ),
        const SizedBox(height: 8),
        Text(title),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner with Profile and Gradient Text Background
            Stack(
              children: [
                Image.asset(
                  "assets/image2.jpg",
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Gradient Overlay to ensure text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 20,
                  bottom: 20,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/image1.jpg"),
                  ),
                ),
                Positioned(
                  left: 110,
                  bottom: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Shaik Jasmine",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20, // Cleaned font scale for screen fitting
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Computer Science Student",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Feature Icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  featureItem(Icons.menu_book, "Books"),
                  featureItem(Icons.assignment, "Tasks"),
                  featureItem(Icons.school, "Marks"),
                  featureItem(Icons.person, "Profile"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: notifications
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Login Clicked"),
                            ),
                          );
                        }
                      : null,
                  child: const Text("Login"),
                ),
                OutlinedButton(
                  onPressed: notifications
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Register Clicked"),
                            ),
                          );
                        }
                      : null,
                  child: const Text("Register"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Notification Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Notifications",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 15),
                Switch(
                  value: notifications,
                  onChanged: (value) {
                    setState(() {
                      notifications = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Counter",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "$counter",
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Counter Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: notifications
                      ? () {
                          setState(() {
                            counter--;
                          });
                        }
                      : null,
                  child: const Text(
                    "-",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: notifications
                      ? () {
                          setState(() {
                            counter++;
                          });
                        }
                      : null,
                  child: const Text(
                    "+",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
