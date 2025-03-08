import 'package:flutter/material.dart';
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CreateClubPage extends StatefulWidget {
  final String userId; // Add a field to store the user_id

  // Constructor to accept user_id
  CreateClubPage({required this.userId});

  @override
  _CreateClubPageState createState() => _CreateClubPageState();
}

class _CreateClubPageState extends State<CreateClubPage> {
  final _formKey = GlobalKey<FormState>();
  String _clubName = '';
  String _clubDescription = '';
  bool _isPrivate = false;
  String _clubTag = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Handle the form submission, e.g., save the club details
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final response = await http.post(
          Uri.parse('$apiUrl/club/new'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({'owner': widget.userId, "name": _clubName, "description" :_clubDescription, "club_tag" : _clubTag}),
      );
      // Navigate back or show a success message
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Club'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Club Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a club name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _clubName = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Club Tag',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a club Tag';
                  }
                  return null;
                },
                onSaved: (value) {
                  _clubTag = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Club Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a club description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _clubDescription = value!;
                },
              ),
              SizedBox(height: 20),
              SwitchListTile(
                title: Text('Private'),
                value: _isPrivate,
                onChanged: (value) {
                  setState(() {
                    _isPrivate = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Done'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}