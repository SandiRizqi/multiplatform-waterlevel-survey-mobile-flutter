import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:firebase_database/firebase_database.dart';  // Firebase Realtime Database
import 'package:cloud_firestore/cloud_firestore.dart';      // Firebase Firestore
import 'package:shared_preferences/shared_preferences.dart';  // Local storage
import 'dart:convert';  // For JSON encoding/decoding
import 'package:starterapp/models/project_data.dart';
import 'package:starterapp/screens/project_data_page.dart';
import 'package:starterapp/widgets/create_project_form.dart';
import 'package:starterapp/screens/welcome_page.dart'; // Import your login page

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final List<Project> _projects = [];
  bool _isOnline = false;  // Tracks online/offline status

  // Firebase references
  final DatabaseReference _statusRef = FirebaseDatabase.instance.ref('status');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;  // Firebase Auth instance

  @override
  void initState() {
    super.initState();
    // Monitor online/offline status
    _monitorOnlineStatus();
    _loadProjects(); // Load projects from local storage
  }

  // Monitor user online/offline status using Firebase Realtime Database
  void _monitorOnlineStatus() {
    _statusRef.onValue.listen((event) {
      final status = event.snapshot.value as bool?;
      setState(() {
        _isOnline = status ?? false;  // Default to offline if null
        if (_isOnline) {
          _syncData();  // Sync data when online
        }
      });
    });
  }

  // Sync project data to Firestore when online
  Future<void> _syncData() async {
    try {
      for (var project in _projects) {
        await _firestore.collection('projects').doc(project.name + "." + project.description).set({
          'dataList': project.dataList.map((data) => {
            'code': data.code,
            'longitude': data.longitude,
            'latitude': data.latitude,
            'nilai': data.nilai,
          }).toList(),
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data synced successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sync data')),
      );
    }
  }

  // Function to add a project
  void _addProject(String name, String description) {
    setState(() {
      final newProject = Project(name: name, description: description);
      _projects.add(newProject);
      _saveProjects();  // Save projects to local storage after adding a project
    });
  }

  // Load projects from local storage
  Future<void> _loadProjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? projectData = prefs.getString('projects');
    if (projectData != null) {
      List<dynamic> decodedData = jsonDecode(projectData);
      setState(() {
        _projects.clear();
        _projects.addAll(decodedData.map((data) {
          final project = Project(
            name: data['name'],
            description: data['description'],
          );
          // Manually add dataList to the project
          project.dataList.addAll((data['dataList'] as List<dynamic>).map((item) => ProjectData(
            code: item['code'],
            longitude: item['longitude'],
            latitude: item['latitude'],
            nilai: item['nilai'],
          )).toList());
          return project;
        }).toList());
      });
    }
  }

  // Save projects to local storage
  Future<void> _saveProjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> projectData = _projects.map((project) => {
      'name': project.name,
      'description': project.description,
      'dataList': project.dataList.map((data) => {
        'code': data.code,
        'longitude': data.longitude,
        'latitude': data.latitude,
        'nilai': data.nilai,
      }).toList(),
    }).toList();
    prefs.setString('projects', jsonEncode(projectData));
  }

  // Logout function
  Future<void> _logout() async {
    await _auth.signOut();  // Firebase sign out
    Navigator.pushReplacement(  // Redirect to the login page after logout
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),  // Assuming you have a login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Projects'),
            const SizedBox(width: 10),
            Icon(
              _isOnline ? Icons.wifi : Icons.wifi_off,
              color: _isOnline ? Colors.green : Colors.red,
              size: 18,
            ),
            if (_isOnline)
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed: _syncData,  // Sync data when button is pressed
                tooltip: 'Sync Data',
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,  // Call the logout function when pressed
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                return Card(
                  child: ListTile(
                    title: Text(project.name),
                    subtitle: Text(project.description),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProjectDataPage(project: project),
                          ),
                        );
                      },
                      child: const Text('Collect Data'),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Create Project'),
                    content: CreateProjectForm(onCreateProject: _addProject),
                  );
                },
              );
            },
            child: const Text('Create Project'),
          ),
        ],
      ),
    );
  }
}
