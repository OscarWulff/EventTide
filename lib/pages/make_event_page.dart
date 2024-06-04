import 'package:flutter/material.dart';

class MakeEventPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Event'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/preview_event');
          },
          child: Text('Go to Preview Event'),
        ),
      ),
    );
  }
}
