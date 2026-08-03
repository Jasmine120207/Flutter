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
      title: 'Student Profile Card',
      home: StudentProfile(),
    );
  }
}

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text("Student Profile Card"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage("assets/profile.jpg"),
              ),
              const SizedBox(height: 15),
              const Text(
                "Sudulaguntla Usha",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Roll No: 24PA1A05L9",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 5),
              const Text(
                "Branch: CSE",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              contactCard(
                Icons.phone,
                "+91 8125056816",
                Colors.green,
              ),
              const SizedBox(height: 15),
              contactCard(
                Icons.email,
                "ushasudulaguntla11@gmail.com",
                Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fixed the syntax declaration here (parentheses for arguments)
  static Widget contactCard(IconData icon, String text, Color color) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 8,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),
          Expanded(
            // Added Expanded to safely handle long text overflow strings
            child: Text(
              text,
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
