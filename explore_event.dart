import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class events_explore extends StatefulWidget {
  const events_explore({super.key});

  @override
  State<events_explore> createState() => _events_exploreState();
}

class _events_exploreState extends State<events_explore> {
  List articles = [];
  List ago_str = [
    'a minute ago',
    'few minutes ago',
    'an hour ago',
    'few hours ago',
    'a day ago',
    'few days ago',
    'weeks ago'
  ];

  get_articles() async {
    List dt = [];
    DateTime current_time = DateTime.now();
    await FirebaseFirestore.instance
        .collection('market_analysis')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        dt.add(doc.data());
      });
    });

    for (int i = 0; i < dt.length; i++) {
      DateTime dtime =
          new DateFormat("yyyy-MM-dd hh:mm:ss").parse("${dt[i]['datetime']}");
      Duration diff = current_time.difference(dtime);
      int min_diff = diff.inMinutes.toInt();

      if (min_diff <= 1) {
        String time = ago_str[0];
        dt[i]['time'] = time;
      } else if (min_diff < 60) {
        String time = ago_str[1];
        dt[i]['time'] = time;
      } else if (min_diff == 60) {
        String time = ago_str[2];
        dt[i]['time'] = time;
      } else if (min_diff < 1440) {
        String time = ago_str[3];
        dt[i]['time'] = time;
      } else if (min_diff == 1440) {
        String time = ago_str[4];
        dt[i]['time'] = time;
      } else if (min_diff < 10008) {
        String time = ago_str[5];
        dt[i]['time'] = time;
      } else {
        String time = ago_str[6];
        dt[i]['time'] = time;
      }
    }
    setState(() {
      articles = dt;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_articles();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    if (articles.length == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            // margin: EdgeInsets.only(left: 10),
            child: Icon(
              Icons.arrow_back_ios,
              color: Color(0xffEFFFFB),
              size: 28,
            ),
          ),
        ),
        backgroundColor: Color(0xff050f14),
        // elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Latest Events",
              style: TextStyle(color: Color(0xff4F98CA), fontSize: 25),
            ),
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
              child: ListView.builder(
                itemCount: articles.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, ind) {
                  int index = articles.length - 1 - ind;
                  return Column(
                    children: [
                      articles[index]['tag'] == 'Alerts'
                          ? Container(
                              margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                              decoration: BoxDecoration(
                                  color: Color(0xffEFFFFB).withOpacity(0.02),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(),
                                        Container(
                                          child: Text(
                                            "${articles[index]['time']}",
                                            style: TextStyle(
                                                color: Color(0xffeffffb)
                                                    .withOpacity(0.5),
                                                fontSize: 10),
                                            overflow: TextOverflow.fade,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      "${articles[index]['title']}",
                                      style: TextStyle(
                                          color: Color(0xffEFFFFB)
                                              .withOpacity(0.8),
                                          fontSize: 20),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox()
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
