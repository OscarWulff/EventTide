import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/swipe_page.dart';
import 'pages/calendar_page.dart';
import 'pages/make_event_page.dart';
import 'pages/preview_event_page.dart';
import 'package:eventtide/firebase_options.dart';
void main() async {
    WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigationWrapper(),
        '/signup': (context) => const SignUpPage(),
        '/swipe': (context) => const SwipePage(),
        '/calendar': (context) => CalendarPage(),
        '/make_event': (context) => const MakeEventPage(),
        '/login': (context) => const LoginPage(),
        '/preview_event': (context) => const PreviewEventPage(),
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
  int _selectedIndex = 1; // Default to 'make' page

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _pages = <Widget>[
    MakeEventPage(),
    SwipePage(),
    CalendarPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(222, 121, 46, 1),
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
            label: 'Calendar',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Database Connected
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'pages/login_page.dart';
// import 'pages/signup_page.dart';
// import 'pages/swipe_page.dart';
// import 'pages/calendar_page.dart';
// import 'pages/make_event_page.dart';
// import 'pages/preview_event_page.dart';
// import 'package:eventtide/firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const EventTideApp());
// }

// class EventTideApp extends StatelessWidget {
//   const EventTideApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'EventTide',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const LoginPage(),
//         '/signup': (context) => const SignUpPage(),
//         '/swipe': (context) => const SwipePage(),
//         '/calendar': (context) => CalendarPage(),
//         '/make_event': (context) => const MakeEventPage(),
//         '/preview_event': (context) => const PreviewEventPage(),
//       },
//     );
//   }
// }