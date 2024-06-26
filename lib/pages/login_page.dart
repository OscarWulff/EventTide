import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:eventtide/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> _signInAsGuest() async {
    try {
      await _auth.signInAnonymously();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error: ${e.code}");
      }
    } catch (e) {
      print("Error signing in as guest: $e");
    }
  }

  void _showCommunityGuidelines(BuildContext context, Function onAccept) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Community Guidelines'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Welcome to EventTide! We want to ensure that everyone has a safe and enjoyable experience. Please adhere to the following guidelines:'),
                SizedBox(height: 10),
                Text('1. Respect others: Be courteous and respectful in all interactions.', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('2. No inappropriate content: Do not post or share content that is offensive, violent, or sexually explicit.'),
                SizedBox(height: 5),
                Text('3. Follow the law: Ensure all your activities comply with local laws and regulations.'),
                SizedBox(height: 5),
                Text('4. Protect your privacy: Do not share personal information such as your address, phone number, or financial information.'),
                SizedBox(height: 5),
                Text('5. Event Deletion: We reserve the right to delete any event that violates our community guidelines without prior notice.'),
                SizedBox(height: 20),
                Text('Thank you for being a part of our community!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Decline'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Accept'),
              onPressed: () {
                Navigator.of(context).pop();
                onAccept();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
        centerTitle: true,
        title: const Text('EventTide'),
        flexibleSpace: Stack(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Transform.translate(
                  offset: Offset(0, 3),
                  child: Image.asset('assets/sandlogo.png', height: 55),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo.png', height: 250),
            SignInButton(
              Buttons.google,
              onPressed: () {
                _showCommunityGuidelines(context, () async {
                  User? user = await _signInWithGoogle();
                  if (user != null) {
                    print('Logged in successfully: ${user.displayName}');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
                    );
                  } else {
                    print('Failed to log in with Google');
                  }
                });
              },
            ),
            SignInButton(
              Buttons.email,
              text: "Continue as Guest",
              onPressed: () {
                _showCommunityGuidelines(context, () async {
                  await _signInAsGuest();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
