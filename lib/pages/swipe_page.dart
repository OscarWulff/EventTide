import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:card_swiper/card_swiper.dart';


class SwipePage extends StatelessWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No events found'));
          }
          final events = snapshot.data!.docs;
          return Swiper(
            itemCount: events.length,
            itemBuilder: (BuildContext context, int index) {
              final event = events[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['EventTitle'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Camp: ${event['CampName']}', style: TextStyle(fontSize: 18)),
                      Text('Description: ${event['EventDescription']}', style: TextStyle(fontSize: 18)),
                      Text('Events People Capacity: ${event['MaxPeople']}', style: TextStyle(fontSize: 18)),
                      Text('Start Time: ${event['StartTime']}', style: TextStyle(fontSize: 18)),
                      Text('End Time: ${event['EndTime']}', style: TextStyle(fontSize: 18)),
                      
                    ],
                  ),
                ),
              );
            },
            layout: SwiperLayout.STACK,
            itemHeight: MediaQuery.of(context).size.height * 0.7,
            itemWidth: MediaQuery.of(context).size.width * 0.8,
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SwipePage(),
  ));
}
