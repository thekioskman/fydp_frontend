import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For caching data
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UploadPostPage extends StatefulWidget {
  @override
  _UploadPostPageState createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  List<File> _images = []; // List to hold up to 9 images
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(); // Controller for title
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  int _user_id = -1;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _user_id = int.tryParse(prefs.getString("user_id") ?? "") ?? -1;
    });
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(); // Allows selecting multiple images
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
        if (_images.length > 9) {
          _images = _images.sublist(0, 9); // Limit to 9 images
        }
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_images.isEmpty || _captionController.text.isEmpty || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one image, enter a title, and a caption')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a multipart request
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/userpost/create'),
      );

      // Attach each image file
      for (var image in _images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files', // This must match the parameter name in FastAPI
            image.path,
            contentType: MediaType('image', 'jpeg'), // Adjust based on the image type
          ),
        );
      }

      // Add the title, caption, and other fields
      request.fields['title'] = _titleController.text; // Add title
      request.fields['description'] = _captionController.text;
      request.fields['owner'] = _user_id.toString();
      request.fields['createdOn'] = DateTime.now().toUtc().subtract(Duration(days: 2)).toIso8601String();

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post uploaded successfully!')),
        );
        setState(() {
          _images.clear();
          _captionController.clear();
          _titleController.clear(); // Clear title field
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload post: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading post: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _isUploading ? null : _uploadPost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display selected images in a grid
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 images per row
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _images.length + 1, // +1 for the "add image" button
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  // Show "add image" button
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 30,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                } else {
                  // Show selected image
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _images.removeAt(index); // Remove image
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 20),
            // Title input field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20),
            // Caption input field
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            if (_isUploading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _uploadPost,
                child: Text('Upload Post'),
              ),
          ],
        ),
      ),
    );
  }
}