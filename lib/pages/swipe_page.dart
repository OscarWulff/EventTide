import 'package:flutter/material.dart';

class SwipePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Swipe'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/calendar');
          },
          child: Text('Go to Calendar'),
        ),
      ),
    );
  }
}
