import 'package:flutter/material.dart';
import 'package:starterapp/screens/welcome_page.dart'; // Import the Welcome Page
import 'package:firebase_core/firebase_core.dart';
import 'package:starterapp/widgets/location_service.dart'; // Import your location service
import 'package:geolocator/geolocator.dart'; // For location service
import 'package:starterapp/screens/option_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Position? _currentPosition;
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      Position position = await LocationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _isLoading = false; // Stop loading after location is fetched
      });
      print('Location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading even on error
      });
      print('Error fetching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAP GIS Survey',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _isLoading
            ? const Scaffold( // Show loading indicator when fetching location
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const WelcomePage(), // Pass location after loading
        '/optionsPage': (context) => const OptionsGridPage(),
      },
    );
  }
}
