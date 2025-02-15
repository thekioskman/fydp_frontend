import 'package:flutter/material.dart';
import 'package:frontend/homepage.dart';
import 'package:frontend/posts/all_posts_page.dart';
import 'video_compare/video_compare.dart';
import 'profile/profilemain.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart'; // https://pub.dev/packages/persistent_bottom_nav_bar
import 'clubs/list_of_user_clubs.dart';
import 'login/login.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userProvider = UserProvider();
  await userProvider.loadUserId(); // Load user ID before app starts
  await dotenv.load();


  runApp(
    ChangeNotifierProvider(
      create: (context) => userProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
	return MaterialApp(
	  title: 'Flutter Demo',
	  theme: ThemeData(
		// This is the theme of your application.
		//
		// TRY THIS: Try running your application with "flutter run". You'll see
		// the application has a purple toolbar. Then, without quitting the app,
		// try changing the seedColor in the colorScheme below to Colors.green
		// and then invoke "hot reload" (save your changes or press the "hot
		// reload" button in a Flutter-supported IDE, or press "r" if you used
		// the command line to start the app).
		//
		// Notice that the counter didn't reset back to zero; the application
		// state is not lost during the reload. To reset the state, use hot
		// restart instead.
		//
		// This works for code too, not just values: Most code changes can be
		// tested with just a hot reload.
		colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
		useMaterial3: true,
	  ),
    home: LoginPage(),
	  );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();


}

class _MainScreenState extends State<MainScreen> {
    PersistentTabController _controller = PersistentTabController(initialIndex: 0);
    String userEmail = "Loading..."; // Default value

    @override
    void initState() {
        super.initState();
        _loadUserEmail(); // Load email when screen initializes
    }

    Future<void> _loadUserEmail() async {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
        userEmail = prefs.getString('user_email') ?? "username not found";
        });
    }

    // List all pages that need to be built here
    List<Widget> _buildScreens() {
        return [
            PostsPage(),
            ProfileMainPage(key: UniqueKey()),
            VideoComparePage(key: UniqueKey()),
        ];
    }

  // Add all screens that can be navigated to here
  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
        PersistentBottomNavBarItem(
            icon: Icon(Icons.home),
            title: "Home",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
            icon: Icon(Icons.person),
            title: "Profile",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
            icon: Icon(Icons.video_collection),
            title: "Compare",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      navBarStyle: NavBarStyle.style3, // Change style as needed
      onItemSelected: (index) { // Refresh the page each time we click on it in the navbar
        setState(() {});

      },
    );
  }

}

