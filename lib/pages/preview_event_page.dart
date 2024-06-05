import 'package:flutter/material.dart';

class PreviewEventPage extends StatelessWidget {
  const PreviewEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Event'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
          child: const Text('Go to Login'),
        ),
      ),
    );
  }
}
