import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http; // For HTTP requests

class CreateEventPage extends StatefulWidget {
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
      // Handle the form submission, e.g., save the event details
      final eventData = {
        'club_id' : 1,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'duration': _eventLengthController.text,
        'date':  DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'time': _selectedTime?.format(context),
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'location': _selectedAddress, // Use the edited address
        'created_on' : DateTime.now().toUtc().subtract(Duration(days: 2)).toIso8601String()
      };
      // Send eventData to your backend
      final response = await http.post(
        Uri.parse('$apiUrl/event/new'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(eventData),
      );
      // Navigate back or show a success message
      Navigator.pop(context);
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
          child: SingleChildScrollView( // Make the form scrollable
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Length of Event in Minutes';
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
                                  border: InputBorder.none, // Remove the default border
                                  contentPadding: EdgeInsets.zero, // Adjust padding
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAddress = value; // Update the address when the user edits it
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
                          // Process the data
                          if (_selectedLocation == null) {
                            // Show a validation message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a location'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          _submitForm();
                        }
                      },
                      child: Text('Add'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Clear the form
                        _titleController.clear();
                        _descriptionController.clear();
                        setState(() {
                          _selectedDate = null;
                          _selectedTime = null;
                          _selectedLocation = null;
                        });
                      },
                      child: Text('Cancel'),
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