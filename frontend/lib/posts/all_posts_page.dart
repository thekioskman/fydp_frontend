import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // For caching data
import 'package:intl/intl.dart'; // For formatting timestamps
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/login/login.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart'; // https://pub.dev/packages/persistent_bottom_nav_bar
import 'package:carousel_slider/carousel_slider.dart';

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
  String? _user_name;
  String s3Bucket = dotenv.env['IMAGE_ENDPOINT'] ?? "";

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
      _user_name = prefs.getString("user_email");
    });
    _fetchPosts();
  }

    void _logout(BuildContext context) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return LoginPage();
            },
          ),
          (_) => false,
        );
    }

    Future<void> _fetchPosts() async {
        if (_isLoading || !_hasMore) {
            print("Already loading or no more posts. Exiting fetch.");
            return;
        }

        print("Fetching posts...");
        print("USERID $_user_id");
        setState(() {
            _isLoading = true;  // Set loading to true
        });

        try {
            final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
            final response = await http.post(
                Uri.parse('$apiUrl/posts'),
                headers: {'Content-Type': 'application/json; charset=UTF-8'},
                body: jsonEncode({'timestamp': DateTime.now().toUtc().subtract(Duration(days: 20)).toIso8601String(), "user_id": _user_id}),
            );

            if (response.statusCode == 200) {
              final List<dynamic> decodedData = jsonDecode(response.body);
              final List<Map<String, dynamic>> newPosts = decodedData.cast<Map<String, dynamic>>();

                //need to build the string URL with the bucket_name, the type of post, and the list of comma seperateed image name strings
                //print(newPosts);
                
                for (Map<String, dynamic> post in newPosts) {
                    if (post["picture_url"] != null) {
                        post["picture_url"] = post["picture_url"].split(',').map((url) => url.trim()).toList();
                    }
                   
                }

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


                    //     const SizedBox(height: 20,),
                    // ElevatedButton(onPressed: () => _logout(context), child: Text("Logout"))
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
        title: Text('Dance Meet', style: GoogleFonts.lato(),),
        centerTitle: false,
        actions: [TextButton(
            onPressed: () {
                _logout(context); // Call your logout function here
            },
            child: Text(
                "Logout",
                style: TextStyle(color: Colors.black),),
            ),
        ],
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
      child: Builder(builder: (context) {

        if (_isLoading) {
            return Center(child: CircularProgressIndicator()); 
        }else if (_posts.isEmpty){
            return ListView(
              physics: AlwaysScrollableScrollPhysics(), // Allows refreshing even if empty
              children: [
                SizedBox(height: 200),
                Icon(Icons.people, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Follow some people to see posts!",
                  style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            );
        }else{
            return ListView.builder(
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
          // User's name above the image
          if (_user_name != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                _user_name ?? "",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

          // Image or Carousel
          if (post["picture_url"].isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: post["picture_url"].length > 1
                  ? CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        enlargeCenterPage: true,
                      ),
                      items: post["picture_url"].map<Widget>((url) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            '$s3Bucket/${post['type']}/${post["id"]}-$url',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          ),
                        );
                      }).toList(),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        '$s3Bucket/${post['type']}/${post["id"]}-${post["picture_url"][0]}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
            ),

          // Caption below the image
          if (post['description'] != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                post['description'],
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),

          // Post title and description
          ListTile(
            title: Text(post['title'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['description']),
                SizedBox(height: 5),
                Text(
                  'Created on: ${_formatTimestamp(post['created_on'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
            ],
        );



                },
            );
        }
      })
    ),
  );
}

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
