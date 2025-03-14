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
  DateTime? _selectedDate;
  LatLng? _selectedLocation;

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

  Future<void> _pickLocation(BuildContext context) async {
    final LatLng? location = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPicker(
          onLocationPicked: (LatLng location) {
            Navigator.pop(context, location);
          },
        ),
      ),
    );

    if (location != null) {
      setState(() {
        _selectedLocation = location;
      });
    }
  }

    void _submitForm() async {
    if (_formKey.currentState!.validate()) {

        final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
        _formKey.currentState!.save();
        // Handle the form submission, e.g., save the event details
        final eventData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
        'location': _selectedLocation != null
            ? {
                'latitude': _selectedLocation!.latitude,
                'longitude': _selectedLocation!.longitude,
                }
            : null,
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
                onTap: () => _pickLocation(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Location',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _selectedLocation == null
                            ? 'Select a location'
                            : 'Lat: ${_selectedLocation!.latitude}, Lng: ${_selectedLocation!.longitude}',
                      ),
                      Icon(Icons.location_on),
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
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}