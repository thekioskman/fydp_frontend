import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // For caching data
import 'package:intl/intl.dart'; // For formatting timestamps

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _latestTimestamp;
  int _user_id = -1;

  @override
  void initState() {
    super.initState();
    _loadCachedTimestamp();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading && _hasMore) {
        print("Triggering fetch due to scroll...");
        //for future use if we want to add more scroling features
      }
    });
  }

  /// **Load cached timestamp from SharedPreferences**
  Future<void> _loadCachedTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _latestTimestamp = prefs.getString('latest_timestamp') ?? DateTime.now().toUtc().subtract(Duration(days: 2)).toIso8601String();
      _user_id = int.tryParse(prefs.getString("user_id") ?? "") ?? -1;
    });
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
  if (_isLoading || !_hasMore) {
    print("Already loading or no more posts. Exiting fetch.");
    return;
  }

  print("Fetching posts...");
  setState(() {
    _isLoading = true;  // Set loading to true
  });

  try {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
    final response = await http.post(
      Uri.parse('$apiUrl/posts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'timestamp': _latestTimestamp, "user_id": _user_id}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> decodedData = jsonDecode(response.body);
      final List<Map<String, dynamic>> newPosts = decodedData.cast<Map<String, dynamic>>();

      setState(() {
        if (newPosts.isNotEmpty) {
          _posts.addAll(newPosts);  // Append new posts to the list
          _latestTimestamp = newPosts.last['created_on'];  // Update the latest timestamp
        } else {
          _hasMore = false;  // No more posts to fetch
        }

        print("Fetched ${newPosts.length} posts");
        _isLoading = false;  // Stop the loading circle
      });
    } else {
      throw Exception('Failed to load posts');
    }
  } catch (e) {
    setState(() {
      _isLoading = false;  // Stop the loading circle on error
    });
    print("Error occurred: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  /// **Format timestamp into a human-readable "Date Posted" string**
  String _formatTimestamp(String timestamp) {
    try {
      DateTime date = DateTime.parse(timestamp).toLocal();  // Convert UTC to local
      return DateFormat('MMM d, yyyy - hh:mm a').format(date);  // Format date
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Posts'),
      centerTitle: true,
    ),
    body: RefreshIndicator(
      onRefresh: () async {
        // Reset state to fetch new posts
        setState(() {
          _hasMore = true; // Allow more fetching
          _posts.clear(); // Clear current posts
        });
        await _fetchPosts(); // Fetch new posts
      },
      child: _isLoading && _posts.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading indicator when no posts
          : ListView.builder(
              controller: _scrollController,
              itemCount: _posts.length,  // We should count the "All Caught Up!" message
              itemBuilder: (context, index) {
                final post = _posts[index];
                
                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text("T", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post['description']), // Updated to 'description'
                                SizedBox(height: 5),
                                Text(
                                  'Created on: ${_formatTimestamp(post['created_on'])}', // Updated to 'created_on'
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
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
                    ),

                  ],
                );
              },
            ),
    ),
  );
}

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
