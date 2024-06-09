import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;

  const EventDetailPage({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Event not found'));
          }
          final event = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['EventTitle'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Camp: ${event['CampName']}', style: TextStyle(fontSize: 18)),
                Text('Description: ${event['EventDescription']}', style: TextStyle(fontSize: 18)),
                Text('Events People Capacity: ${event['MaxPeople']}', style: TextStyle(fontSize: 18)),
                Text('Day of Event: ${event['Days']}', style: TextStyle(fontSize: 18)),
                Text('Start Time: ${event['StartTime']}', style: TextStyle(fontSize: 18)),
                Text('End Time: ${event['EndTime']}', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}
