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
      title: 'Responsive UI Menu',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,

      // Mobile AppBar
      appBar: isMobile
          ? AppBar(
              title: const Text(
                "Responsive UI",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,

      // Mobile Drawer
      drawer: isMobile
          ? const Drawer(
              child: AppMenuList(
                iconsOnly: false,
                isRowWise: false,
              ),
            )
          : null,

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/wallpaper.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: isMobile
            ? const Center(
                child: Text(
                  "Mobile Screen",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    // Large Screen Horizontal Menu
                    Container(
                      height: 70,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.4),
                      child: const AppMenuList(
                        iconsOnly: true,
                        isRowWise: true,
                      ),
                    ),

                    // Main Content
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Large Screen",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// --------------------------------------------------
// Reusable Menu List
// --------------------------------------------------

class AppMenuList extends StatelessWidget {
  final bool iconsOnly;
  final bool isRowWise;

  const AppMenuList({
    super.key,
    required this.iconsOnly,
    required this.isRowWise,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: isRowWise ? Axis.horizontal : Axis.vertical,
      padding: isRowWise
          ? const EdgeInsets.symmetric(horizontal: 16.0)
          : EdgeInsets.zero,
      children: [
        _buildHeader(),

        // Home
        _buildMenuItem(
          Icons.home,
          "Home",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),

        // Services
        _buildMenuItem(
          Icons.miscellaneous_services,
          "Services",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ServicesPage(),
              ),
            );
          },
        ),

        // Feedback
        _buildMenuItem(
          Icons.feedback,
          "Feedback",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FeedbackPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  // --------------------------------------------------
  // Header
  // --------------------------------------------------

  Widget _buildHeader() {
    if (iconsOnly) {
      return Padding(
        padding: isRowWise
            ? const EdgeInsets.only(right: 24.0)
            : const EdgeInsets.symmetric(vertical: 24.0),
        child: const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white24,
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
      );
    }

    return const DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Navigation Menu",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // Menu Item
  // --------------------------------------------------

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    if (iconsOnly) {
      return Padding(
        padding: isRowWise
            ? const EdgeInsets.symmetric(horizontal: 16.0)
            : const EdgeInsets.symmetric(vertical: 12.0),
        child: IconButton(
          icon: Icon(
            icon,
            color: Colors.white70,
            size: 28,
          ),
          onPressed: onTap,
          tooltip: title,
        ),
      );
    }

    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white70,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}

// --------------------------------------------------
// Home Page
// --------------------------------------------------

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: const Center(
        child: Text(
          "Welcome to the Home Page!",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Services Page
// --------------------------------------------------

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Services"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            "Our Services\n\n"
            "• Web Development\n"
            "• Mobile App Development\n"
            "• UI/UX Design\n"
            "• Software Development\n"
            "• Technical Support",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              height: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Feedback Page
// --------------------------------------------------

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // TextEditingController to read feedback
  final TextEditingController feedbackController = TextEditingController();

  String message = "";

  void submitFeedback() {
    String feedback = feedbackController.text;

    if (feedback.isNotEmpty) {
      setState(() {
        message = "Feedback Submitted";
      });

      print("User Feedback: $feedback");

      feedbackController.clear();
    } else {
      setState(() {
        message = "Please enter your feedback";
      });
    }
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Enter your feedback",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // TextField
            TextField(
              controller: feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Type your feedback here...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: submitFeedback,
              child: const Text("Submit"),
            ),

            const SizedBox(height: 20),

            // Result message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
