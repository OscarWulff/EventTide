import 'package:flutter/material.dart';
import 'calendar_page.dart';

class PreviewEventPage extends StatelessWidget {
  final Event event;

  const PreviewEventPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
      ),
      body: Stack(
        children: [
          if (event.imageUrl.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Optional: Add a dark overlay for better text visibility
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20), // Padding from the top
                Text(
                  'Title: ${event.title}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Description: ${event.description}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  'Camp: ${event.campName}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  'Max People: ${event.maxPeople}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  'Start Time: ${event.startTime}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  'End Time: ${event.endTime}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
