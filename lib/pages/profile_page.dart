import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Import your login page file

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

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
              const SizedBox(height: 8),
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL ?? 'https://via.placeholder.com/150'),
                radius: 40,
              ),
              ElevatedButton(
                onPressed: () {
                  // Sign out the user
                  FirebaseAuth.instance.signOut();
                  // Navigate back to the login page
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text('Log out'),
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
