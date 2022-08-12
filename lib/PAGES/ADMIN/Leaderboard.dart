import 'package:flutter/material.dart';
import 'package:humanly/COMPONENTS/AdminAppDrawer.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/COMPONENTS/ReviewTile.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/COMPONENTS/PDFCreator.dart';

class Leaderboard extends StatefulWidget {
  Leaderboard({Key key}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  double myRatings = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: currentUser == null
          ? AdminAppDrawer(
              selectedScreen: '/leaderboard',
            )
          : null,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 5.0,
        iconTheme: IconTheme.of(context).copyWith(
          color: Colors.white,
        ),
        title: Text(
          'Leaderboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(top: 10.0),
        child: FutureBuilder(
          future: getLeaderboard(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.none || !snap.hasData) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    Text(
                      'Please Wait...',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              // List<int> indexes = [0,1,2,3,4];
              List<Map<String, dynamic>> _data = snap.data;

              _data.sort((a, b) {
                double rate1 = a['totalRating'] != 0
                    ? a['rating'].toInt() / a['totalRating'].toInt()
                    : 0;
                double rate2 = b['totalRating'] != 0
                    ? b['rating'].toInt() / b['totalRating'].toInt()
                    : 0;
                return rate1 < rate2 ? 1 : 0;
              });

              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: _data.map((e) {
                            double avg = e['totalRating'] != 0
                                ? e['rating'].toInt() / e['totalRating'].toInt()
                                : 0;

                            if (currentUser != null) {
                              if (e['uid'] == currentUser.uid) {
                                this.myRatings = avg;
                              }
                            }
                            return ReviewTile(
                              name: currentUser == null
                                  ? e['name']
                                  : (currentUser.uid == e['uid']
                                      ? 'YOU'
                                      : e['name']),
                              contact: 'valid user',
                              rating: avg,
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: currentUser != null ? 65 : 0),
                    ],
                  ),
                  currentUser != null
                      ? Material(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0)),
                          elevation: 8.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 65,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8.0),
                            child: RawMaterialButton(
                              onPressed: () {
                                PDFCreator()
                                    .createPDF(currentUser.name, myRatings);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              fillColor: kPrimaryColor,
                              elevation: 5.0,
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Claim your certificate',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'Sanchez',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
