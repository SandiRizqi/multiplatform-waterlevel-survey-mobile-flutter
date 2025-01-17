import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // For date management

class CreateProjectForm extends StatefulWidget {
  final void Function(String, String) onCreateProject;

  const CreateProjectForm({super.key, required this.onCreateProject});

  @override
  State<CreateProjectForm> createState() => _CreateProjectFormState();
}

class _CreateProjectFormState extends State<CreateProjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _tahunController = TextEditingController();
  String _selectedBulan = '01';
  String _selectedHari = '01';
  String _selectedPeriode = '1';

  @override
  void initState() {
    super.initState();
    _tahunController.text = DateFormat('yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _tahunController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final projectName =
          'Project: ${_tahunController.text}-${_selectedBulan}-${_selectedHari}';
      final projectDescription = 'Periode: $_selectedPeriode';
      widget.onCreateProject(projectName, projectDescription);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Input for Tahun (Year)
          TextFormField(
            controller: _tahunController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Tahun'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the year';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Dropdown for Bulan (Month)
          DropdownButtonFormField<String>(
            value: _selectedBulan,
            items: List.generate(12, (index) {
              final month = (index + 1).toString().padLeft(2, '0');
              return DropdownMenuItem(value: month, child: Text(month));
            }),
            onChanged: (value) {
              setState(() {
                _selectedBulan = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'Bulan'),
          ),
          const SizedBox(height: 16),

          // Dropdown for Hari (Day)
          DropdownButtonFormField<String>(
            value: _selectedHari,
            items: List.generate(31, (index) {
              final day = (index + 1).toString().padLeft(2, '0');
              return DropdownMenuItem(value: day, child: Text(day));
            }),
            onChanged: (value) {
              setState(() {
                _selectedHari = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'Hari'),
          ),
          const SizedBox(height: 16),

          // Dropdown for Periode
          DropdownButtonFormField<String>(
            value: _selectedPeriode,
            items: const [
              DropdownMenuItem(value: '1', child: Text('1')),
              DropdownMenuItem(value: '2', child: Text('2')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPeriode = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'Periode'),
          ),
          const SizedBox(height: 32),

          // Submit Button
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Create Project'),
          ),
        ],
      ),
    );
  }
}
