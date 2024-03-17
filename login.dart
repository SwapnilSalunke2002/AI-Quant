import 'package:ai_quant/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class mylogin extends StatefulWidget {
  const mylogin({super.key});

  @override
  State<mylogin> createState() => _myloginState();
}

class _myloginState extends State<mylogin> {
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xff050f14),
      body: Container(
        height: _height,
        width: _width,
        child: Stack(
          children: [
            Container(
              height: _height,
              width: _width,
              child: ListView(
                children: [
                  SizedBox(height: _height/4,),
                  Center(
                    child: Container(
                      
                      child: Image.asset('assets/logo/launch_logo.png',height: _width/1.7,)
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: Text(
                        "Welcome!",
                        style:
                            TextStyle(color: Color(0xffEFFFFB), fontSize: 27),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      // margin: EdgeInsets.all(20),
                      child: Text(
                        "Sign In To Your Account...",
                        style: TextStyle(
                            color: Color(0xffEFFFFB).withOpacity(0.7),
                            fontSize: 17),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 55,
                margin: EdgeInsets.fromLTRB(50, 20, 50, 30),
                decoration: BoxDecoration(
                    color: Color(0xffEFFFFB),
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                      onPressed: () async {
                        await googleLogin();
                        var user = FirebaseAuth.instance.currentUser;
                        print(user);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => myuser(),
                            ));
                      },
                      icon: Image.asset(
                        'assets/icons/google.png',
                        height: 30,
                      ),
                      label: Text('Sign In with Google')),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future googleLogin() async {
    final googleSignIn = GoogleSignIn();
    GoogleSignInAccount? _user;
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
