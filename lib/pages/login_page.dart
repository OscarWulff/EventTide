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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  
  Future<void> _signInAsGuest() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with temporary account.");
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
        centerTitle: true,
        title: const Text('Welcome to EventTide'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/Roskilde_logo.png', height: 150,),
            SignInButton(
              Buttons.google,
              onPressed: () async {
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
              },
            ),
            const SizedBox(height: 8),
            Container(
              height: 37,
              decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.0),
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.01)),
              ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: Offset(0, 2), // Changes position of shadow to the bottom only
                  ),
                ],
              ),
              child: SignInButtonBuilder(
                text: 'Login as Guest',
                icon: Icons.person,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: _signInAsGuest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
