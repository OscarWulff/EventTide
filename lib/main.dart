import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/swipe_page.dart';
import 'pages/calendar_page.dart';
import 'pages/make_event_page.dart';
import 'pages/preview_event_page.dart';

void main() {
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
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/swipe': (context) => const SwipePage(),
        '/calendar': (context) => const CalendarPage(),
        '/make_event': (context) => const MakeEventPage(),
        '/preview_event': (context) => const PreviewEventPage(),
      },
    );
  }
}
