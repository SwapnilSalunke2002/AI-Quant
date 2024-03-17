import 'package:ai_quant/src/profilepage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:ai_quant/src/explore_event.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CarouselController _caro_controller = CarouselController();
  DraggableScrollableController _drag_controller =
      DraggableScrollableController();
  late String tag;
  late bool move_sheet;
  late bool _refreshed;

  List market_data = [];
  List bullish_data = [];
  List bearish_data = [];
  List overview_data = [];
  bool bullish = false;
  bool bearish = false;

  @override
  void initState() {
    super.initState();
    tag = 'Bullish';
    move_sheet = false;
    get_articles();
    _refreshed = true;
  }

  get_articles() async {
    List data = [];
    List bullish_stocks = [];
    List bearish_stocks = [];
    List market_overview = [];

    List ago_str = [
      'a minute ago',
      'few minutes ago',
      'an hour ago',
      'few hours ago',
      'a day ago',
      'few days ago',
      'weeks ago'
    ];

    DateTime current_time = DateTime.now();

    await FirebaseFirestore.instance
        .collection('market_analysis')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        data.add(doc.data());

        if (doc['tag'] == 'Bullish') {
          bullish_stocks.add(doc.data());
        } else if (doc['tag'] == 'Bearish') {
          bearish_stocks.add(doc.data());
        } else {
          market_overview.add(doc.data());
        }
      });
    });
    List markets = [bullish_stocks, bearish_stocks, market_overview];

    for (int n = 0; n < markets.length; n++) {
      for (int i = 0; i < markets[n].length; i++) {
        DateTime dtime = new DateFormat("yyyy-MM-dd hh:mm:ss")
            .parse("${markets[n][i]['datetime']}");
        Duration diff = current_time.difference(dtime);
        int min_diff = diff.inMinutes.toInt();
        if (min_diff <= 2) {
          String time = ago_str[0];
          markets[n][i]['time'] = time;
        } else if (min_diff < 60) {
          String time = ago_str[1];
          markets[n][i]['time'] = time;
        } else if (min_diff < 60 || min_diff < 120) {
          String time = ago_str[2];
          markets[n][i]['time'] = time;
        } else if (min_diff < 1440) {
          String time = ago_str[3];
          markets[n][i]['time'] = time;
        } else if (min_diff == 1440 || min_diff < 1440 * 2) {
          String time = ago_str[4];
          markets[n][i]['time'] = time;
        } else if (min_diff < 10008 || min_diff < 10008 * 2) {
          String time = ago_str[5];
          markets[n][i]['time'] = time;
        } else {
          String time = ago_str[6];
          markets[n][i]['time'] = time;
        }
      }
    }

    setState(() {
      market_data = data;
      bullish_data = bullish_stocks;
      bearish_data = bearish_stocks;
      overview_data = market_overview;
    });
    print(bullish_data);
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    List stocks = [bullish_data, bearish_data];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Color(0xff050f14),
          appBar: AppBar(
            backgroundColor: Color(0xff050f14),
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      get_articles();
                    });
                  },
                  child: Text(
                    "Stocks Undercover",
                    style: TextStyle(color: Color(0xffEFFFFB), fontSize: 25),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xff31C6D4).withOpacity(0.05)),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0, left: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _caro_controller.animateToPage(0);
                          },
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Opacity(
                                opacity: tag == 'Bullish' ? 1 : 0.4,
                                child: Image.asset(
                                  'assets/icons/bull.png',
                                  height: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _caro_controller.animateToPage(1);
                          },
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Opacity(
                                opacity: tag == 'Bullish' ? 0.4 : 1,
                                child: Image.asset(
                                  'assets/icons/bear.png',
                                  height: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          // bottomSheet: _showBottomSheet(),
          body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('market_analysis')
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot_dt) {
                print(snapshot_dt.data);
                return Container(
                  height: _height,
                  width: _width,
                  child: Stack(
                    children: [
                      Container(
                          height: _height,
                          width: _width,
                          child: CarouselSlider.builder(
                            itemCount: stocks.length,
                            carouselController: _caro_controller,
                            itemBuilder: (BuildContext context, int itemIndex,
                                int pageViewIndex) {
                              return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: stocks[itemIndex].length,
                                itemBuilder: (context, index) {
                                  if (bullish_data.length == 0 &&
                                      bearish_data.length == 0) {
                                    return Scaffold(
                                      backgroundColor: Color(0xff050f14),
                                      body: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  index = stocks[itemIndex].length - 1 - index;
                                  double rate =
                                      stocks[itemIndex][index]['Rating'];
                                  double unsure = 10 - rate;
                                  return Column(
                                    children: [
                                      stocks[itemIndex][index]['tag'] ==
                                                  'Bullish' ||
                                              stocks[itemIndex][index]['tag'] ==
                                                  'Bearish'
                                          ? GestureDetector(
                                              onTap: () {
                                                _bottomsheet(
                                                    stocks[itemIndex][index]);
                                                print(stocks[itemIndex][index]
                                                    ['latest_events']);
                                              },
                                              child: Container(
                                                height: _height / 6,
                                                width: _width,
                                                margin: EdgeInsets.fromLTRB(
                                                    15, 15, 15, 0),
                                                decoration: BoxDecoration(
                                                    color: Color(0xffEFFFFB)
                                                        .withOpacity(0.05),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              15, 15, 15, 0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: _width / 1.7,
                                                            child: Text(
                                                              "${stocks[itemIndex][index]['StockName']}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffEFFFFB),
                                                                  fontSize: 20),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                            ),
                                                          ),
                                                          Container(
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  child: Text(
                                                                    "${stocks[itemIndex][index]['time']}",
                                                                    style: TextStyle(
                                                                        color: Color(0xffeffffb).withOpacity(
                                                                            0.5),
                                                                        fontSize:
                                                                            10),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .fade,
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 2,
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .query_builder,
                                                                  size: 10,
                                                                  color: Color(
                                                                          0xffeffffb)
                                                                      .withOpacity(
                                                                          0.7),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              15, 0, 15, 15),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width: _width / 1.7,
                                                            child: Text(
                                                              "${stocks[itemIndex][index]['title']}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                          0xffEFFFFB)
                                                                      .withOpacity(
                                                                          0.6),
                                                                  fontSize: 15),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 3,
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 70,
                                                            width: 70,
                                                            child: Stack(
                                                              children: [
                                                                Container(
                                                                    child:
                                                                        PieChart(
                                                                  dataMap: {
                                                                    '${stocks[itemIndex][index]['tag']}':
                                                                        rate,
                                                                    'unsure':
                                                                        unsure
                                                                  },
                                                                  animationDuration:
                                                                      Duration(
                                                                          milliseconds:
                                                                              800),
                                                                  chartLegendSpacing:
                                                                      25,
                                                                  chartRadius:
                                                                      _width /
                                                                          4,

                                                                  colorList: [
                                                                    stocks[itemIndex][index]['tag'] ==
                                                                            'Bullish'
                                                                        ? Color(
                                                                            0xff50D890)
                                                                        : Color(
                                                                            0xffFF1E1E),
                                                                    Color(
                                                                        0xff050f14)
                                                                  ],
                                                                  initialAngleInDegree:
                                                                      270,
                                                                  chartType:
                                                                      ChartType
                                                                          .ring,
                                                                  ringStrokeWidth:
                                                                      5,
                                                                  legendOptions:
                                                                      LegendOptions(
                                                                    showLegendsInRow:
                                                                        false,
                                                                    legendPosition:
                                                                        LegendPosition
                                                                            .right,
                                                                    showLegends:
                                                                        false,
                                                                    legendTextStyle:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),

                                                                  chartValuesOptions:
                                                                      ChartValuesOptions(
                                                                    showChartValueBackground:
                                                                        true,
                                                                    showChartValues:
                                                                        false,
                                                                    showChartValuesInPercentage:
                                                                        false,
                                                                    showChartValuesOutside:
                                                                        false,
                                                                    decimalPlaces:
                                                                        1,
                                                                  ),
                                                                )),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10),
                                                                        color: stocks[itemIndex][index]['tag'] ==
                                                                                'Bullish'
                                                                            ? Color(0xff50D890).withOpacity(0.1)
                                                                            : Color(0xffFF1E1E).withOpacity(0.1)),
                                                                    child: Padding(
                                                                        padding: const EdgeInsets.all(5.0),
                                                                        child: stocks[itemIndex][index]['tag'] == 'Bullish'
                                                                            ? Text(
                                                                                '${stocks[itemIndex][index]['tag']}',
                                                                                style: TextStyle(color: Color(0xff50D890), fontSize: 10),
                                                                              )
                                                                            : Text(
                                                                                '${stocks[itemIndex][index]['tag']}',
                                                                                style: TextStyle(color: Color(0xffFF1E1E), fontSize: 10),
                                                                              )),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                      index == 0
                                          ? SizedBox(
                                              height: 150,
                                            )
                                          : SizedBox()
                                    ],
                                  );
                                },
                              );
                            },
                            options: CarouselOptions(
                              aspectRatio: _width / _height,
                              viewportFraction: 1,
                              initialPage: 0,
                              enableInfiniteScroll: false,
                              onPageChanged: (index, reason) {
                                if (index == 0) {
                                  _caro_controller.animateToPage(0);
                                  setState(() {
                                    tag = 'Bullish';
                                  });
                                } else {
                                  _caro_controller.animateToPage(1);
                                  setState(() {
                                    tag = 'Bearish';
                                  });
                                }
                              },
                            ),
                          )),
                    ],
                  ),
                );
              }),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                print("${notification.extent}");
                if (notification.extent < 0.4) {
                  setState(() {
                    move_sheet = false;
                  });
                } else {
                  setState(() {
                    move_sheet = true;
                  });
                }
                return true;
              },
              child: DraggableScrollableSheet(
                controller: _drag_controller,
                expand: false,
                initialChildSize: 0.0,
                minChildSize: 0.0,
                maxChildSize: 1,
                snap: true,
                builder: (_, controller) {
                  return Container(
                    height: _height,
                    width: _width,
                    decoration: BoxDecoration(
                        boxShadow: [
                          move_sheet
                              ? BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 3),
                                  blurRadius: _height / 2,
                                  spreadRadius: _height)
                              : BoxShadow()
                        ],
                        color: Color(0xff050f14),
                        borderRadius: BorderRadius.circular(20)),
                    child: Stack(
                      children: [
                        ListView.builder(
                          physics: BouncingScrollPhysics(),
                          controller: controller, 
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            int len = overview_data.length;
                            int ind = (len - 1) - index;
                            return Material(
                              elevation: 0,
                              borderOnForeground: true,
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  index == 0
                                      ? SizedBox(
                                          height: 50,
                                        )
                                      : SizedBox(),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    decoration: BoxDecoration(
                                        color:
                                            Color(0xffEFFFFB).withOpacity(0.02),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 15, 15, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              
                                              Container(
                                                child: Text(
                                                  "${overview_data[ind]['tag']}",
                                                  style: TextStyle(
                                                      color: Color(0xff4F98CA)
                                                          .withOpacity(0.9),
                                                      fontSize: 20),
                                                  overflow: TextOverflow.fade,
                                                  maxLines: 2,
                                                ),
                                              ),
                                              SizedBox(),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: overview_data[ind]['texts'].length,
                                               itemBuilder: (context, index) {
                                                return Column(
                                                  children: [
                                                    Text(
                                                      "${overview_data[ind]['texts'][index]}",
                                                      style: TextStyle(
                                                          color: Color(0xffEFFFFB)
                                                              .withOpacity(0.9),
                                                          fontSize: 17),
                                                      textAlign: TextAlign.justify,
                                                    ),
                                                    SizedBox(height: 10,)
                                                  ],
                                                );
                                              }
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ind == 0
                                      ? SizedBox(
                                          height: 150,
                                        )
                                      : SizedBox()
                                ],
                              ),
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: _width,
                              decoration: BoxDecoration(
                                color: Color(0xff050f14),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Market Overview",
                                      style: TextStyle(
                                          color: Color(0xff4F98CA),
                                          fontSize: 25),
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            get_articles();
                                          });
                                        },
                                        child: Icon(Icons.refresh,
                                            size: 30, color: Color(0xffEFFFFB)))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.all(20),
            height: 70,
            width: _width,
            decoration: BoxDecoration(
              color: Color(0xff050f14),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 3),
                    blurRadius: 10,
                    spreadRadius: 10)
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => events_explore(),
                          ));
                    },
                    child: Icon(
                      Icons.explore,
                      color: Color(0xff4F98CA).withOpacity(0.8),
                      size: 28,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (move_sheet) {
                        _drag_controller.jumpTo(0.0);
                        setState(() {
                          move_sheet = false;
                        });
                      } else {
                        _drag_controller.jumpTo(0.7);
                        setState(() {
                          move_sheet = true;
                        });
                      }
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xff4F98CA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 3),
                                blurRadius: 10,
                                spreadRadius: 10)
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                Icons.travel_explore,
                                color: Color(0xff4F98CA),
                                size: 28,
                              ),
                              Text(
                                'Market Overview',
                                style: TextStyle(
                                    color: Color(0xff4F98CA), fontSize: 15),
                              )
                            ],
                          ),
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => myprofile(),
                          ));
                    },
                    child: Icon(
                      Icons.person,
                      color: Color(0xff4F98CA).withOpacity(0.8),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



  _bottomsheet(article) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Stack(
          children: [
            Container(
              width: _width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Color(0xff050f14)),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.new_label_rounded,
                          color: Color(0xff4F98CA),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Stock Insights",
                          style:
                              TextStyle(color: Color(0xff4F98CA), fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${article['title']}",
                        style: TextStyle(
                            color: Color(0xffEFFFFB).withOpacity(0.9),
                            fontSize: 20),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.newspaper_rounded,
                          color: Color(0xff4F98CA),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Latest Events",
                          style:
                              TextStyle(color: Color(0xff4F98CA), fontSize: 20),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   // width: _width,
                  //   // height: _height,
                  //   // margin: EdgeInsets.all(15),
                  //   child: ListView.builder(
                  //       shrinkWrap: true,
                  //       physics: NeverScrollableScrollPhysics(),
                  //       itemCount: article['Events'].length,
                  //       itemBuilder: (context, index) {
                  //         return Column(
                  //           children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${article['Events']}",
                      style: TextStyle(
                          color: Color(0xffEFFFFB).withOpacity(0.9),
                          fontSize: 20),
                    ),
                  ),
                  //             index == article['latest_events'].length - 1
                  //                 ? SizedBox(
                  //                     height: 100,
                  //                   )
                  //                 : SizedBox()
                  //           ],
                  //         );
                  //       }),
                  // ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 40,
                    color: Color(0xffEFFFFB),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
