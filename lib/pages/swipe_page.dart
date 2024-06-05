import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SwipePage extends StatelessWidget {
  const SwipePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(222, 121, 46, 1),
        title: const Text('Event',style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Remove the ElevatedButton widget and its SizedBox spacer
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Events').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No events found');
                  }
                  final events = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        title: Text(event['EventTitle']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description: ${event['EventDescription']}'),
                            Text('Camp: ${event['CampName']}'),
                            Text('Duration: ${event['Duration']} hours'),
                            Text('Start Time: ${event['StartTime']}'),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
