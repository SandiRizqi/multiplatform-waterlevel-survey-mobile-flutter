import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // For LatLng
import 'package:starterapp/models/project_data.dart'; // Ensure this import points to your Project and ProjectData models
import 'package:starterapp/screens/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

class ProjectDataPage extends StatefulWidget {
  final Project project; // This will hold the selected project

  const ProjectDataPage({super.key, required this.project});

  @override
  State<ProjectDataPage> createState() => _ProjectDataPageState();
}

class _ProjectDataPageState extends State<ProjectDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nilaiController = TextEditingController();

  double? _longitude;
  double? _latitude;

  LatLng? _currentPosition;
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadData(); // Load project-specific data from shared preferences
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nilaiController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is permanently denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _longitude = position.longitude;
      _latitude = position.latitude;
      _currentPosition = LatLng(position.latitude, position.longitude);

      // Ensure the map is rendered before moving the map
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentPosition != null) {
          _mapController.move(_currentPosition!, 15.0);
        }
      });
    });
  }

  void _addData() {
    if (_formKey.currentState!.validate() && _longitude != null && _latitude != null) {
      final newData = ProjectData(
        code: _codeController.text,
        longitude: _longitude!,
        latitude: _latitude!,
        nilai: double.parse(_nilaiController.text),
      );

      setState(() {
        widget.project.dataList.add(newData); // Add new data to the current project's dataList
        _codeController.clear();
        _nilaiController.clear();
      });

      _saveData(); // Save the updated project data locally

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data Added!')),
      );
    }
  }

  void _editData(ProjectData data, int index) {
    _codeController.text = data.code;
    _nilaiController.text = data.nilai.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Data'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Code'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a code';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _longitude?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Longitude (auto-filled)',
                  ),
                  enabled: false,
                ),
                TextFormField(
                  initialValue: _latitude?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Latitude (auto-filled)',
                  ),
                  enabled: false,
                ),
                TextFormField(
                  controller: _nilaiController,
                  decoration: const InputDecoration(labelText: 'Nilai'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a nilai';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    widget.project.dataList[index] = ProjectData(
                      code: _codeController.text,
                      longitude: data.longitude,
                      latitude: data.latitude,
                      nilai: double.parse(_nilaiController.text),
                    );
                  });
                  _saveData(); // Save the updated data locally after editing
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteData(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.project.dataList.removeAt(index); // Remove the selected data
              });
              _saveData(); // Save the updated data after deletion
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String projectJson = jsonEncode(widget.project.toJson());
    await prefs.setString('project_${widget.project.name}', projectJson); // Save data specific to this project
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? projectJson = prefs.getString('project_${widget.project.name}'); // Load project-specific data

    if (projectJson != null) {
      final loadedProject = Project.fromJson(jsonDecode(projectJson));
      setState(() {
        widget.project.dataList.clear(); // Clear the existing dataList
        widget.project.dataList.addAll(loadedProject.dataList); // Load the saved data for this project
      });
    }
  }

  void _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(),
      ),
    );

    if (result != null) {
      setState(() {
        _codeController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            _currentPosition != null
                ? Container(
                    height: 350,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition ?? LatLng(0, 120),
                        initialZoom: 10.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition!,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.blue,
                                size: 30.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 350,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.project.dataList.length,
                itemBuilder: (context, index) {
                  final data = widget.project.dataList[index];
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteData(index);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text('Code: ${data.code}'),
                        subtitle: Text(
                          'Longitude: ${data.longitude}, Latitude: ${data.latitude}, Nilai: ${data.nilai}',
                        ),
                        onTap: () => _editData(data, index), // Open edit dialog on tap
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
                      title: const Text('Add New Data'),
                      content: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _codeController,
                              decoration: InputDecoration(
                                labelText: 'Code',
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.qr_code_scanner),
                                  onPressed: _scanQRCode,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a code';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              initialValue: _longitude?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Longitude (auto-filled)',
                              ),
                              enabled: false,
                            ),
                            TextFormField(
                              initialValue: _latitude?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Latitude (auto-filled)',
                              ),
                              enabled: false,
                            ),
                            TextFormField(
                              controller: _nilaiController,
                              decoration: const InputDecoration(labelText: 'Nilai'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a nilai';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _addData();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Add Data'),
            ),
          ],
        ),
      ),
    );
  }
}
