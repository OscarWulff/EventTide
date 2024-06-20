import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'make_event_page.dart';
import 'package:eventtide/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventtide/Services/custom_cache_manager.dart';
import 'package:intl/intl.dart';
import 'map_page.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;
  final String mode;

  const EventDetailPage({super.key, required this.eventId, required this.mode});

  Future<void> _leaveEvent(BuildContext context, String eventId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final joinRegistry = FirebaseFirestore.instance
            .collection('Events')
            .doc(eventId)
            .collection('Join_Registry');

        final querySnapshot =
            await joinRegistry.where('email', isEqualTo: user.email).get();

        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully left the event')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave the event')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is logged in')),
      );
    }
  }

  void _showLocationOnMap(BuildContext context, Offset location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoomableMapPage(
          onLocationSelected: (Offset _) {},
          initialLocation: location,
          enableZoom: true, // Enable zoom for the EventDetailPage
          editable: false, // Make the location not editable
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mode == 'edit'
          ? AppBar(
              title: const Text('Edit Event'),
              centerTitle: true,
              backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          : AppBar(
              title: const Text('Event Details'),
              centerTitle: true,
              backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
            ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('Events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Event not found'));
          }
          final event = snapshot.data!.data() as Map<String, dynamic>;
          final imageUrl = event['imageUrl'] ?? '';

          // Parse and format StartTime and EndTime
          final DateFormat formatter = DateFormat('dd.MMM | kk:mm');
          final DateTime startTime = DateTime.parse(event['StartTime']);
          final String formattedStartTime = formatter.format(startTime);
          final DateTime endTime = DateTime.parse(event['EndTime']);
          final String formattedEndTime = formatter.format(endTime);

          return Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl.isNotEmpty)
                CachedNetworkImage(
                  cacheManager: CustomCacheManager.instance,
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )
              else
                Image.asset(
                  'assets/RosRos.png',
                  fit: BoxFit.cover,
                ),
              Container(
                color: Colors.black.withOpacity(0.5),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
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
                        Icon(Icons.access_time_filled, color: Colors.white),
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
                    const SizedBox(height: 20),
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
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(222, 121, 46, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('Events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Event not found'));
          }
          final event = snapshot.data!.data() as Map<String, dynamic>;
          return BottomNavigationBar(
            backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black,
            items: [
              if (mode == 'edit') ...[
                const BottomNavigationBarItem(
                  icon: Icon(Icons.edit),
                  label: 'Edit',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.delete),
                  label: 'Delete',
                ),
              ] else if (mode == 'view') ...[
                const BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz, color: Colors.transparent),
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.exit_to_app),
                  label: 'Leave',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz, color: Colors.transparent),
                  label: '',
                ),
              ],
            ],
            onTap: (index) {
              if (mode == 'edit' && index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MakeEventPage(
                      eventData: {
                        'id': eventId,
                        ...event,
                      },
                    ),
                  ),
                );
              } else if (mode == 'edit' && index == 1) {
                FirebaseFirestore.instance
                    .collection('Events')
                    .doc(eventId)
                    .delete()
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Event deleted successfully')),
                  );
                  Navigator.pop(context);
                });
              } else if (mode == 'view' && index == 1) {
                _leaveEvent(context, eventId);
                Navigator.pushNamed(context, '/main');
              }
            },
          );
        },
      ),
    );
  }
}
