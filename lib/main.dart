import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/swipe_page.dart';
import 'pages/calendar_page.dart';
import 'pages/make_event_page.dart';
import 'pages/preview_event_page.dart';

void main() {
  runApp(EventTideApp());
}

class EventTideApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventTide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/swipe': (context) => SwipePage(),
        '/calendar': (context) => CalendarPage(),
        '/make_event': (context) => MakeEventPage(),
        '/preview_event': (context) => PreviewEventPage(),
      },
    );
  }
}
