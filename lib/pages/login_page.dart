import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoggedIn = false;
  Map<String, dynamic> _userObj = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DBestech"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: _isLoggedIn
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    _userObj["picture"]["data"]["url"],
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error_outline),
                  ),
                  Text(_userObj["name"]),
                  Text(_userObj["email"]),
                  TextButton(
                      onPressed: () {
                        FacebookAuth.instance.logOut().then((value) {
                          setState(() {
                            _isLoggedIn = false;
                            _userObj = {};
                          });
                        });
                      },
                      child: Text("Logout"))
                ],
              )
            : Center(
                child: ElevatedButton(
                  child: Text("Login with Facebook"),
                  onPressed: () async {
                    final LoginResult result = await FacebookAuth.instance
                        .login(permissions: ["public_profile", "email"]);

                    if (result.status == LoginStatus.success) {
                      final userData =
                          await FacebookAuth.instance.getUserData();
                      setState(() {
                        _isLoggedIn = true;
                        _userObj = userData;
                      });
                    } else {
                      print('Login failed: ${result.status}');
                      print('Message: ${result.message}');
                    }
                  },
                ),
              ),
      ),
    );
  }
}
