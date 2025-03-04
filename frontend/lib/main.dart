import 'package:flutter/material.dart';

import 'package:frontend/posts/all_posts_page.dart';
import 'video_compare/video_compare.dart';
import 'profile/profilemain.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart'; // https://pub.dev/packages/persistent_bottom_nav_bar
import 'login/login.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userProvider = UserProvider();
  await userProvider.loadUserId(); // Load user ID before app starts
  await dotenv.load();

  //Uncomment if you want to clear the cookies
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.clear();


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
      title: 'Dance Meet App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 245, 245, 245)),
        useMaterial3: true,
      ),
      home: LoginPage(),
      initialRoute: "/",
	  );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();


}

class _MainScreenState extends State<MainScreen> {
  PersistentTabController _controller = PersistentTabController(initialIndex: 0);
    

  @override
  void initState() {
      super.initState();
  }

  // List all pages that need to be built here
  List<Widget> _buildScreens() {
    final userIdString = Provider.of<UserProvider>(context, listen: false).userId;
    final int userId = int.tryParse(userIdString ?? "") ?? -1; // Ensures userId is always int

      return [
          PostsPage(),
          ProfileMainPage(profileUserId: userId,),
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
            routeAndNavigatorSettings: RouteAndNavigatorSettings(
              initialRoute: "/",
            )
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

