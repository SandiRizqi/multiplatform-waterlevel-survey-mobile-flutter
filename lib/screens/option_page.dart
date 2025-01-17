import 'package:flutter/material.dart';
import 'package:starterapp/screens/project_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:starterapp/screens/welcome_page.dart';


class OptionsGridPage extends StatelessWidget {
  const OptionsGridPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // After logging out, navigate to the login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    } catch (e) {
      // Handle errors if any
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Try again!')),
      );
    }
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout(context); // Call the logout function when pressed
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 10, // Spacing between columns
            mainAxisSpacing: 10, // Spacing between rows
            childAspectRatio: 1, // Aspect ratio of each card
          ),
          itemCount: options.length, // Number of items
          itemBuilder: (context, index) {
            final option = options[index];

            return GestureDetector(
              onTap: () {
                // Navigate to the corresponding page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => option.page,
                  ),
                );
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(option.icon, size: 70, color: option.color),
                    const SizedBox(height: 10),
                    Text(option.title, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Define the model for the grid options
class Option {
  final String title;
  final IconData icon;
  final Widget page;
  final Color color;

  Option({required this.title, required this.icon, required this.page, required this.color});
}

// Example of a list of options
final List<Option> options = [
  Option(title: 'TMAT', icon: Icons.water_rounded, page: const ProjectListScreen(), color: Colors.blue),
  Option(title: 'Hotspot', icon: Icons.fireplace_rounded, page: Page2(), color: Colors.red),
  Option(title: 'Deforestation', icon: Icons.landscape_rounded, page: Page3(), color: Colors.green),
  Option(title: 'Patok', icon: Icons.border_all_rounded, page: Page4(), color: Colors.black),
];



class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 2')),
      body: Center(child: Text('This is Page 2')),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 3')),
      body: Center(child: Text('This is Page 3')),
    );
  }
}

class Page4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 4')),
      body: Center(child: Text('This is Page 4')),
    );
  }
}

class Page5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 5')),
      body: Center(child: Text('This is Page 5')),
    );
  }
}
