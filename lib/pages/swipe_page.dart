import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:card_swiper/card_swiper.dart';

class SwipePage extends StatelessWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
              final event = events[index].data() as Map<String, dynamic>;
              final imageUrl = event.containsKey('imageUrl') ? event['imageUrl'] : '';

              return Card(
                child: Stack(
                  children: [
                    if (imageUrl.isNotEmpty)
                      Positioned.fill(
                        child: Image.network(
                          imageUrl,
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
                          Text(
                            event['EventTitle'],
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Camp: ${event['CampName']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'Description: ${event['EventDescription']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'Events People Capacity: ${event['MaxPeople']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'Start Time: ${event['StartTime']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'End Time: ${event['EndTime']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red, size: 50),
                              onPressed: () {
                                // No action
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.check, color: Colors.green, size: 50),
                              onPressed: () {
                                // No action
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            layout: SwiperLayout.STACK,
            itemHeight: MediaQuery.of(context).size.height,
            itemWidth: MediaQuery.of(context).size.width,
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
