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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text('Name: ${user.displayName ?? 'Anonymous'}', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Email: ${user.email ?? 'No email'}', style: TextStyle(fontSize: 18)),
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
                    backgroundColor: const Color.fromRGBO(222, 121, 46, 1), // Set the button color to orange
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
                          return Center(child: Text('No events found'));
                        }
                        final events = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return ListTile(
                              title: Text(event['EventTitle']),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetailPage(eventId: event.id),
                                    ),
                                  );
                                },
                                child: const Text('View', style: TextStyle(color: Colors.black)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(222, 121, 46, 1), // Set the button color to orange
                                ),
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
              const Text('No user information available', style: TextStyle(fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }
}
