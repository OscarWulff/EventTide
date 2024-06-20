import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'dart:math';
import 'package:eventtide/Services/custom_cache_manager.dart';
import 'map_page.dart';
import 'package:intl/intl.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final SwiperController swiperController = SwiperController();
  late Future<List<QueryDocumentSnapshot>> _eventsFuture;
  bool _isTextVisible = true;

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
      eventSnapshot =
          await FirebaseFirestore.instance.collection('Events').get();
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
      joinedEventIds =
          joinSnapshot.docs.map((doc) => doc['eventId'] as String).toList();
    } catch (e) {
      return [];
    }

    // Filter events to exclude those already joined
    List<QueryDocumentSnapshot> filteredEvents =
        allEvents.where((event) => !joinedEventIds.contains(event.id)).toList();

    filteredEvents.shuffle(Random());

    return filteredEvents;
  }

  Future<void> _prefetchImages(List<String> imageUrls) async {
    for (String url in imageUrls) {
      await CustomCacheManager.instance.downloadFile(url);
    }
  }

  void _showLocationOnMap(BuildContext context, Offset location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoomableMapPage(
          onLocationSelected: (Offset _) {},
          initialLocation: location,
          enableZoom: true, // Enable zoom for the SwipePage
          editable: false, // Make the location not editable
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.85),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('No events found',
                    style: TextStyle(color: Colors.white)));
          }
          final events = snapshot.data!;

          // Prefetch initial set of images
          final imageUrls = events
              .take(10)
              .map((event) {
                final data = event.data() as Map<String, dynamic>;
                return data.containsKey('imageUrl')
                    ? data['imageUrl'] as String
                    : '';
              })
              .where((url) => url.isNotEmpty)
              .toList();
          _prefetchImages(imageUrls);

          return Swiper(
            itemCount: events.length,
            itemBuilder: (BuildContext context, int index) {
              final event = events[index].data() as Map<String, dynamic>;
              final imageUrl = event.containsKey('imageUrl')
                  ? event['imageUrl'] as String
                  : '';
              final eventId = events[index].id;

              // Parse and format StartTime and EndTime
              final DateFormat formatter = DateFormat('dd.MMM | kk:mm');
              final DateTime startTime = DateTime.parse(event['StartTime']);
              final String formattedStartTime = formatter.format(startTime);
              final DateTime endTime = DateTime.parse(event['EndTime']);
              final String formattedEndTime = formatter.format(endTime);

              return GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 0) {
                    _joinEvent(context, eventId);
                    swiperController.previous();
                  }
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! < 0) {
                    swiperController.next();
                  }
                },
                onTap: () {
                  setState(() {
                    _isTextVisible = !_isTextVisible;
                  });
                },
                child: Card(
                  child: Stack(
                    children: [
                      if (imageUrl.isNotEmpty)
                        Positioned.fill(
                          child: CachedNetworkImage(
                            cacheManager: CustomCacheManager.instance,
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      if (_isTextVisible)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(
                                0.5), // Optional: Add a dark overlay for better text visibility
                          ),
                        ),
                      if (_isTextVisible)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['EventTitle'],
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Camp: ${event['CampName']}',
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.description, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Description: ${event['EventDescription']}',
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.people, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Capacity: ${event['MaxPeople']} people',
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Starts: $formattedStartTime',
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.access_time_filled,
                                      color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Ends: $formattedEndTime',
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  final location = event['Location'];
                                  if (location != null) {
                                    final Offset eventLocation = Offset(
                                      location['dx'],
                                      location['dy'],
                                    );
                                    _showLocationOnMap(context, eventLocation);
                                  }
                                },
                                child: Text(
                                  'Show Location',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(222, 121, 46, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_isTextVisible)
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
                                  icon: Icon(Icons.close,
                                      color: Colors.red, size: 50),
                                  onPressed: () {
                                    swiperController.next();
                                  },
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.check,
                                      color: Colors.green, size: 50),
                                  onPressed: () {
                                    _joinEvent(context, eventId);
                                    swiperController.previous();
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
