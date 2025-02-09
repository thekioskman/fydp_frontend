import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http; // For HTTP requests

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchPosts();
      }
    });
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a network call
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    final response = await http.post(
        Uri.parse('$apiUrl/dancemeet/posts'),
        
        headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
            'user_id': "something", //TODO store user id as cookie or variable on login
            }
        )
    );



    final newPosts = List.generate(10, (index) {
      return {
        'club': 'Club ${_posts.length + index + 1}',
        'body': 'This is a sample post by Club ${_posts.length + index + 1}.',
        'imageUrl': _posts.length + index % 2 == 0
            ? 'image_url'
            : null, // Some posts have images, some don't
      };
    });

    setState(() {
      _posts.addAll(newPosts);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
        centerTitle: true,
      ),
      body: _posts.isEmpty && _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _posts.length + 1,
              itemBuilder: (context, index) {
                if (index == _posts.length) {
                  return _isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : SizedBox.shrink();
                }

                final post = _posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          post['club'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(post['body']),
                      ),
                      if (post['imageUrl'] != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              post['imageUrl'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}