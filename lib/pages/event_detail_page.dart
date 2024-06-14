import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;
  final String mode; // Add this parameter to indicate the entry mode

  const EventDetailPage({super.key, required this.eventId, required this.mode});

  Future<void> _leaveEvent(BuildContext context, String eventId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final joinRegistry = FirebaseFirestore.instance
            .collection('Events')
            .doc(eventId)
            .collection('Join_Registry');

        final querySnapshot = await joinRegistry.where('email', isEqualTo: user.email).get();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Event not found'));
          }
          final event = snapshot.data!.data() as Map<String, dynamic>;
          final imageUrl = event['imageUrl'] ?? '';
          return Stack(
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
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20), // Padding from the top
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
                            style: const TextStyle(fontSize: 20, color: Colors.white),
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
                            style: const TextStyle(fontSize: 20, color: Colors.white),
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
                            style: const TextStyle(fontSize: 20, color: Colors.white),
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
                            'Start Time: ${event['StartTime']}',
                            style: const TextStyle(fontSize: 20, color: Colors.white),
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
                            'End Time: ${event['EndTime']}',
                            style: const TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
        selectedItemColor: Colors.black,  // Set selected item color to black
        unselectedItemColor: Colors.black, // Set unselected item color to black
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
          ] else if (mode == 'Publishing') ...[
            const BottomNavigationBarItem(
              icon: Icon(Icons.publish),
              label: 'Publish',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Edit',
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
                builder: (context) => EditEventPage(eventId: eventId),
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
          } else if (mode == 'Publishing' && index == 0) {
            FirebaseFirestore.instance
                .collection('Events')
                .doc(eventId)
                .update({'Published_TF': true})
                .then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Event published successfully')),
              );
              Navigator.pop(context);
            });
          } else if (mode == 'Publishing' && index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditEventPage(eventId: eventId),
              ),
            );
          } else if (mode == 'view' && index == 1) {
            // Logic to disjoin the event
            _leaveEvent(context, eventId);
            Navigator.pushNamed(context, '/main');
            
          }
        },
      ),
    );
  }
}

class EditEventPage extends StatelessWidget {
  final String eventId;
  const EditEventPage({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement your edit event page here
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
      ),
      body: Center(
        child: Text('Edit Event Page for $eventId'),
      ),
    );
  }
}
