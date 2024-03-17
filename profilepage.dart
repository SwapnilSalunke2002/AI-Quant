import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class myprofile extends StatefulWidget {
  const myprofile({super.key});

  @override
  State<myprofile> createState() => _myprofileState();
}

class _myprofileState extends State<myprofile> {
  var user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Color(0xffEFFFFB),
              size: 28,
            ),
          ),
          backgroundColor: Color(0xff050f14),
          // elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(
              //   "My Profile",
              //   style: TextStyle(color: Color(0xffEFFFFB), fontSize: 25),
              // ),
            ],
          ),
        ),
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
                  physics: BouncingScrollPhysics(),
                  children: [
                    Center(
                      child: Container(
                          height: _width / 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffEFFFFB).withOpacity(0.9),
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                '${user!.photoURL}',
                                fit: BoxFit.contain,
                              ))),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                        child: Text(
                      "${user!.displayName}",
                      style: TextStyle(color: Color(0xffEFFFFB), fontSize: 25),
                    )),
                    Center(
                        child: Text(
                      "${user!.email}",
                      style: TextStyle(
                          color: Color(0xffEFFFFB).withOpacity(0.7),
                          fontSize: 17),
                    )),
                    SizedBox(
                      height: _height / 4,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Opacity(
                          opacity: 0.5,
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: ListTile(
                                  leading: Icon(
                                    Icons.share_rounded,
                                    color: Color(0xff4F98CA),
                                  ),
                                  minLeadingWidth: 2,
                                  title: Text(
                                    "Share with friends",
                                    style: TextStyle(
                                        color: Color(0xff4F98CA), fontSize: 20),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: ListTile(
                                  leading: Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xff4F98CA),
                                  ),
                                  minLeadingWidth: 2,
                                  title: Text(
                                    "Terms & Conditions",
                                    style: TextStyle(
                                        color: Color(0xff4F98CA), fontSize: 20),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: ListTile(
                                  leading: Icon(
                                    Icons.feedback_outlined,
                                    color: Color(0xff4F98CA),
                                  ),
                                  minLeadingWidth: 2,
                                  title: Text(
                                    "Feedback",
                                    style: TextStyle(
                                        color: Color(0xff4F98CA), fontSize: 20),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: ListTile(
                                  leading: Icon(
                                    Icons.settings,
                                    color: Color(0xff4F98CA),
                                  ),
                                  minLeadingWidth: 2,
                                  title: Text(
                                    "Settings",
                                    style: TextStyle(
                                        color: Color(0xff4F98CA), fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                          },
                          child: ListTile(
                            leading: Icon(
                              Icons.logout_rounded,
                              color: Color(0xff4F98CA),
                            ),
                            minLeadingWidth: 2,
                            title: Text(
                              "Logout",
                              style: TextStyle(
                                  color: Color(0xff4F98CA), fontSize: 20),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
