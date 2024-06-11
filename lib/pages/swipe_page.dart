import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_swiper/card_swiper.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final SwiperController swiperController = SwiperController();
  late Future<List<QueryDocumentSnapshot>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchEvents();
  }

  Future<void> _joinEvent(BuildContext context, String eventId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Events')
            .doc(eventId)
            .collection('Join_Registry')
            .add({
          'email': user.email,
          'eventId': eventId,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully joined the event')),
        );
        setState(() {
          _eventsFuture = _fetchEvents();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join the event')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is logged in')),
      );
    }
  }

  Future<List<QueryDocumentSnapshot>> _fetchEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    // Fetch all events
    QuerySnapshot eventSnapshot;
    try {
      eventSnapshot = await FirebaseFirestore.instance.collection('Events').get();
    } catch (e) {
      return [];
    }

    List<QueryDocumentSnapshot> allEvents = eventSnapshot.docs;

    // Fetch joined events
    QuerySnapshot joinSnapshot;
    try {
      joinSnapshot = await FirebaseFirestore.instance
          .collectionGroup('Join_Registry')
          .where('email', isEqualTo: user.email)
          .get();
    } catch (e) {
      return [];
    }

    List<String> joinedEventIds;
    try {
      joinedEventIds = joinSnapshot.docs.map((doc) => doc['eventId'] as String).toList();
    } catch (e) {
      return [];
    }

    // Filter events to exclude those already joined
    List<QueryDocumentSnapshot> filteredEvents = allEvents.where((event) => !joinedEventIds.contains(event.id)).toList();

    return filteredEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found', style: TextStyle(color: Colors.white)));
          }
          final events = snapshot.data!;
          return Swiper(
            itemCount: events.length,
            itemBuilder: (BuildContext context, int index) {
              final event = events[index].data() as Map<String, dynamic>;
              final imageUrl = event.containsKey('imageUrl') ? event['imageUrl'] : '';
              final eventId = events[index].id;

              return GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                    _joinEvent(context, eventId);
                    swiperController.next();
                  }
                },
                child: Card(
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
                                  swiperController.previous();
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
                                  _joinEvent(context, eventId);
                                  swiperController.next();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            layout: SwiperLayout.STACK,
            itemHeight: MediaQuery.of(context).size.height,
            itemWidth: MediaQuery.of(context).size.width,
            controller: swiperController,
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
