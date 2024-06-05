import 'package:flutter/material.dart';

class MakeEventPage extends StatelessWidget {
  const MakeEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Event'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/preview_event');
          },
          child: const Text('Go to Preview Event'),
        ),
      ),
    );
  }
}
