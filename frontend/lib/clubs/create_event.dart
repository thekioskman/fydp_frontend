import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:flutter/services.dart';

class CreateEventPage extends StatefulWidget {
  final int club_id;

  const CreateEventPage({super.key, required this.club_id});
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _eventLengthController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  LatLng? _selectedLocation;
  String? _selectedAddress;

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now(); // Get current date
    final formattedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return formattedTime.toIso8601String(); // Include timezone information
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickLocation(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPicker(
          onLocationPicked: (LatLng location, String address) {
            Navigator.pop(context, {'location': location, 'address': address});
          },
        ),
      ),
    );
    if (!mounted) return;

    if (result != null) {
      LatLng selectedLocation = result['location'];
      String selectedAddress = result['address'];
      print('Selected Location: ${selectedLocation.latitude}, ${selectedLocation.longitude}');
      print('Selected Address: $selectedAddress');
      setState(() {
        _selectedLocation = selectedLocation;
        _selectedAddress = selectedAddress;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      _formKey.currentState!.save();

      // Combine date and time into a single DateTime object
      final combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final eventData = {
        'club_id': widget.club_id,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'duration_minutes': _eventLengthController.text,
        'date': combinedDateTime.toIso8601String(), // Include timezone information
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'location': _selectedAddress, // Use the edited address
        'created_on': DateTime.now().toUtc().toIso8601String(), // Include timezone information
      };

      // Send eventData to your backend
      final response = await http.post(
        Uri.parse('$apiUrl/clubevent/create'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(eventData),
      );

      if (response.statusCode == 200) {
        // Success: Navigate back or show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Navigate back to the previous screen
      } else {
        // Error: Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Event Title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Event Description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _eventLengthController,
                  decoration: InputDecoration(
                    labelText: 'Event Duration (Minutes)',
                  ),
                   keyboardType: TextInputType.number, // Set keyboard to numeric
                    inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    ],

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Length of Event in Minutes';
                    }
                    if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _selectedDate == null
                              ? 'Select a date'
                              : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        ),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectTime(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Time',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _selectedTime == null
                              ? 'Select a time'
                              : _selectedTime!.format(context),
                        ),
                        Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () => _pickLocation(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Location',
                    ),
                    child: _selectedLocation == null
                        ? Text('Select a location')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                initialValue: _selectedAddress,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAddress = value;
                                  });
                                },
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedLocation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a location'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            _submitForm();
                          }
                        }
                      },
                      child: Text('Add'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _titleController.clear();
                        _descriptionController.clear();
                        _eventLengthController.clear();
                        setState(() {
                          _selectedDate = null;
                          _selectedTime = null;
                          _selectedLocation = null;
                          _selectedAddress = "";
                        });
                      },
                      child: Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}