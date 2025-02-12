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
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _fetchPosts();
      }
    });
  }

  /// **Load cached timestamp from SharedPreferences**
  Future<void> _loadCachedTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _latestTimestamp = prefs.getString('latest_timestamp') ?? DateTime.now().toUtc().toIso8601String();
      _user_id = prefs.getInt("user_id") ?? -1;
    });
    _fetchPosts();
  }

  /// **Fetch posts from the API**
  Future<void> _fetchPosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
        final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
        final response = await http.post(
            Uri.parse('$apiUrl/posts'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'timestamp': _latestTimestamp, "user_id" : _user_id}),
        );

        if (response.statusCode == 200) {
            final List<dynamic> decodedData = jsonDecode(response.body);
            final List<Map<String, dynamic>> newPosts = decodedData.cast<Map<String, dynamic>>();

            setState(() {
                if (newPosts.isNotEmpty) {
                    _posts.addAll(newPosts);
                    _latestTimestamp = newPosts.last['timestamp'];

                    // Save latest timestamp
                    SharedPreferences.getInstance().then((prefs) {
                    prefs.setString('latest_timestamp', _latestTimestamp!);
                    });
                } else {
                    _hasMore = false;
                }
                _isLoading = false;
            
            });
        } else {
            throw Exception('Failed to load posts');
        }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// **Format timestamp into a human-readable "Date Posted" string**
  String _formatTimestamp(String timestamp) {
    try {
      DateTime date = DateTime.parse(timestamp).toLocal(); // Convert UTC to local
      return DateFormat('MMM d, yyyy - hh:mm a').format(date); // Format date
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
      body: _posts.isEmpty && _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _posts.length + 1,
              itemBuilder: (context, index) {
                if (index == _posts.length) {
                  return _hasMore
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'All Caught Up!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                }

                final post = _posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(post['club'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post['body']),
                            SizedBox(height: 5),
                            Text(
                              'Posted on: ${_formatTimestamp(post['timestamp'])}',
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
