import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login_page.dart';
import 'pages/swipe_page.dart';
import 'pages/calendar_page.dart';
import 'pages/make_event_page.dart';
import 'pages/profile_page.dart'; // Import the profile page
import 'package:eventtide/Services/firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EventTideApp());
}

class EventTideApp extends StatelessWidget {
  const EventTideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventTide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthCheck(), // Use AuthCheck as the home widget
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainNavigationWrapper(),
        '/swipe': (context) => const SwipePage(),
        '/calendar': (context) => const CalendarPage(),
        '/profile': (context) => const ProfilePage(), // Add the profile page route
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show a loading indicator while checking authentication status
        }
        if (snapshot.hasData) {
          return const MainNavigationWrapper(); // If logged in, navigate to the main screen
        }
        return const LoginPage(); // If not logged in, navigate to the login screen
      },
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({Key? key}) : super(key: key);

  @override
  _MainNavigationWrapperState createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 1; // Default to 'swipe' page

  static const List<Widget> _pages = <Widget>[
    MakeEventPage(),
    SwipePage(),
    CalendarPage(),
  ];

  static const List<String> _titles = <String>[
    'Create Event',
    'Swipe Events',
    'Calendar',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
              centerTitle: true,
              backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black, // Background color for the icon
                  child: IconButton(
                    icon: const Icon(Icons.person),
                    color: Colors.white, // Icon color
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                ),
              ),
              title: Text(
                _titles[_selectedIndex],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              flexibleSpace: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Transform.translate(
                        offset: Offset(0, 10), // Adjust the second value to move the image down
                        child: Image.asset(
                          'assets/sandlogo.png',
                          height: 55,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swipe),
            label: 'Swipe Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_sharp),
            label: 'Events',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
