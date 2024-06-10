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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl.isNotEmpty)
              Image.network(event.imageUrl, height: 200, fit: BoxFit.cover),
            SizedBox(height: 20),
            Text('Title: ${event.title}', style: TextStyle(fontSize: 18)),
            Text('Description: ${event.description}',
                style: TextStyle(fontSize: 18)),
            Text('Camp: ${event.campName}', style: TextStyle(fontSize: 18)),
            Text('Max People: ${event.maxPeople}',
                style: TextStyle(fontSize: 18)),
            Text('Start Time: ${event.startTime}',
                style: TextStyle(fontSize: 18)),
            Text('End Time: ${event.endTime}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
