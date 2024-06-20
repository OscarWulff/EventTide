import 'package:eventtide/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'event_detail_page.dart'; // Import the event detail page

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final double backgroundOpacity = 0.3; // Adjust the opacity as needed

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Name: ',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              user.displayName ?? 'Anonymous',
                              style: TextStyle(fontSize: 18, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Email: ',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              user.email ?? 'No email',
                              style: TextStyle(fontSize: 18, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Sign out the user
                    FirebaseAuth.instance.signOut();
                    // Navigate back to the login page
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('Log out', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Set the button color to grey
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                color: const Color.fromRGBO(222, 121, 46, 1),
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'My Events',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    // Background image within the events container
                    Positioned.fill(
                      child: Opacity(
                        opacity: backgroundOpacity, // Adjust the opacity value as needed
                        child: Image.asset(
                          'assets/Roskilde_logo.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Events')
                          .where('SubmittedBy', isEqualTo: user.email)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No events found', style: TextStyle(color: Colors.black)));
                        }
                        final events = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event['EventTitle'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20, // Adjust the font size as needed
                                            fontWeight: FontWeight.bold, // Optional: Make the text bold
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Join_Registry')
                                              .where('eventId', isEqualTo: event.id)
                                              .snapshots(),
                                          builder: (context, joinSnapshot) {
                                            if (joinSnapshot.connectionState == ConnectionState.waiting) {
                                              return Text(
                                                'Loading participants...',
                                                style: TextStyle(color: Colors.black),
                                              );
                                            }
                                            if (!joinSnapshot.hasData || joinSnapshot.data!.docs.isEmpty) {
                                              return Text(
                                                'Participants: 0/${event['MaxPeople']}',
                                                style: TextStyle(color: Colors.black),
                                              );
                                            }
                                            final participantCount = joinSnapshot.data!.docs.length;
                                            return Text(
                                              'Participants: $participantCount/${event['MaxPeople']}',
                                              style: TextStyle(color: Colors.black),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EventDetailPage(eventId: event.id, mode: 'edit'),
                                        ),
                                      );
                                    },
                                    child: const Text('View', style: TextStyle(color: Colors.black)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(222, 121, 46, 1), // Set the button color to orange
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text('No user information available', style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ],
        ),
      ),
    );
  }
}
