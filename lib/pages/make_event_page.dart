import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MakeEventPage extends StatelessWidget {
  const MakeEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        title: const Text('Make Event'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.black,
              child: const Column(  // Correct syntax: child: Column(...)
               children: [
                 Text( //Images
                    style: TextStyle(color: Colors.white),
                    'Upload images to describe your event',
                      ),
                widget(child: Image.asset('assets/gravko.jpg')),     
               TextField( //Title of event
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Title of event',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                 TextField( //Description of event
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Describe your event',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextField( //Max number people
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Maximum number of people',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    keyboardType: TextInputType.number, //Only numbers as input
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/preview_event');
              },
              child: const Text('Go to Preview Event'),
            ),
          ],
        ),
      ),
    );
  }
}
