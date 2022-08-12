import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:humanly/COMPONENTS/ActionButton.dart';
import 'package:humanly/COMPONENTS/AppDrawer.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/COMPONENTS/LocationTracker.dart';
import 'package:humanly/COMPONENTS/LogoHeaders.dart';
import 'package:humanly/COMPONENTS/StatBubble.dart';
import 'package:humanly/COMPONENTS/RangeSelector.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/GuestModel.dart';
import 'package:humanly/MODELS/HelperModel.dart';
import 'package:humanly/MODELS/UserLocationModel.dart';
import 'package:humanly/MODELS/UserModel.dart';
import 'package:humanly/PAGES/HelperRoute.dart';
import 'package:humanly/SERVICES/LocationService.dart';
import 'package:humanly/main.dart';
import 'package:humanly/notificationservice.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;
// import 'package:push_notification/push_notification.dart';

class User extends StatelessWidget {
  const User({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDarkColor,
      drawer: AppDrawer(),
      body: StreamProvider<GuestModel>(
        create: (context) => getSosAlerts(),
        child: UserScreen(),
      ),
    );
  }
}

class UserScreen extends StatefulWidget {
  UserScreen({Key key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool showPop = false;
  bool isLoading;
  GuestModel lastReq;
  // Notificator notification;

  String notificationKey = 'key';
  String _bodyText = 'notification test';

  @override
  void initState() {
    isLoading = false;
    lastReq = GuestModel(id: '-1');
    super.initState();
    tz.initializeTimeZones();
    // notification = Notificator(
    //   onPermissionDecline: () {
    //     // ignore: avoid_print
    //     print('permission decline');
    //   },
    //   onNotificationTapCallback: (notificationData) {
    //     setState(
    //       () {
    //         _bodyText = 'notification open: '
    //             '${notificationData[notificationKey].toString()}';
    //       },
    //     );
    //   },
    // )..requestPermissions(
    //     requestSoundPermission: true,
    //     requestAlertPermission: true,
    //   );
  }

  Future<bool> showAlertDialog(GuestModel data) async {
    await Future.delayed(Duration(seconds: 3));
    GuestModel _request = data;

    bool _return = false;

    // callbackDispatcher();

    NotificationService().showNotification(
        1,
        "SOS ALERT",
        "Hey, ${_request.username} needs your help at ${_request.address}, can you help him/her?",
        10);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'SOS ALERT!!!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        content: Text(
          'Hey, ${_request.username} needs your help at ${_request.address}, can you help him/her?',
          style: TextStyle(
            fontSize: 14.0,
          ),
        ),
        actions: [
          RawMaterialButton(
            onPressed: () {
              _return = false;
              Navigator.of(_).pop();
            },
            fillColor: Colors.transparent,
            elevation: 0.0,
            child: Container(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                'Nope',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          RawMaterialButton(
            onPressed: () {
              _return = true;
              Navigator.of(_).pop();
            },
            fillColor: kPrimaryColor,
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                'Yeah Sure',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    // callbackDispatcher();
    // notification.show(
    //   1,
    //   'hello',
    //   'this is test',
    //   imageUrl: 'https://www.lumico.io/wp-019/09/flutter.jpg',
    //   data: {notificationKey: '[notification data]'},
    //   notificationSpecifics: NotificationSpecifics(
    //     AndroidNotificationSpecifics(
    //       autoCancelable: true,
    //     ),
    //   ),
    // );
    return _return;
  }

  Future<void> handleSOS(BuildContext context, GuestModel data) async {
    if (data != null) {
      if (!showPop) {
        showPop = true;

        int distance = calculateDistance(data.lat, data.lng).round();

        if (data != null &&
            data.resolved == false &&
            lastReq.id != data.id &&
            distance <= data.sosRange) {
          lastReq = data;
          NotificationService()
              .showNotification(1, "SOS", "Someone needs your Help", 10);
          await showAlertDialog(data).then((value) async {
            if (value) {
              try {
                var _address = await Geocoder.local
                    .findAddressesFromCoordinates(Coordinates(
                  currentUser.lat,
                  currentUser.lng,
                ));
                var _first = _address.first;

                HelperModel _helper = HelperModel(
                  id: currentUser.uid,
                  name: currentUser.name,
                  contact: currentUser.contact,
                  location: _first.addressLine,
                  lat: currentUser.lat,
                  lng: currentUser.lng,
                );
                await FirebaseFirestore.instance
                    .collection('sosAlert')
                    .doc(data.id)
                    .collection('helpers')
                    .doc(_helper.id)
                    .set(_helper.toMap());

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelperRoute(
                      sos: data,
                    ),
                  ),
                ).then((value) async {
                  if (value != null) {
                    if (value == 'done') {
                      showFlushBar(
                        context: context,
                        title: 'Great Job...',
                        message: 'Your help will be appreciated',
                      );
                    } else {
                      await FirebaseFirestore.instance
                          .collection('sosAlert')
                          .doc(value)
                          .collection('helpers')
                          .doc(currentUser.uid)
                          .delete();
                    }
                  }
                  setState(() {
                    showPop = false;
                  });
                });
              } catch (e) {
                print(e.toString());
                showFlushBar(
                  context: context,
                  title: 'Error Occured!!!',
                  message: 'Failed to give responce',
                );
                setState(() {
                  showPop = false;
                });
              }
            } else {
              setState(() {
                showPop = false;
              });
            }
          });
        } else {
          setState(() {
            showPop = false;
          });
        }
      }
    }
  }

  Future<bool> callOnFcmApiSendPushNotifications(
      {String title, String body}) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to": "/topics/myTopic",
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "type": '0rder',
        "id": '28',
        "click_action": 'FLUTTER_NOTIFICATION_CLICK',
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAHlUiDOo:APA91bHaN_Psk43aT5DSCx_XCDj9fAxZ20qut9h3WObO0bBaqoqrCCpr3r0h9g4cRKcT6e0BGSByK-CRekYUYs4-hkc3_OmfkrECLZUWOomsJFk8OX4AcZfIupLCmk47L5YpGUua0MMC' // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      print('test ok push CFM');
      return true;
    } else {
      print(' CFM error');
      // on failure do sth
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var _data = Provider.of<GuestModel>(context);
    if (_data != null && _data.uid != currentUser.uid && !_data.resolved) {
      handleSOS(context, _data);
    }

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      opacity: 0.5,
      progressIndicator: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(kPrimaryColor),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Please Wait...',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
      child: Stack(
        children: [
          StreamProvider<List<UserModel>>(
            create: (context) => getMembersData(),
            child: LocationTracker(),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(15.0),
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 10.0),
                          Builder(
                            builder: (context) => InkWell(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: Icon(
                                FlutterIcons.menu_fea,
                                size: 32.0,
                              ),
                            ),
                          ),
                          Expanded(
                            child: LogoHeaders(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamProvider<List<UserModel>>(
                    create: (context) => getMembersData(),
                    child: Column(
                      children: [
                        StatBubble(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: FloatingActionButton(
                        backgroundColor: kPrimaryColor,
                        onPressed: () async {
                          callOnFcmApiSendPushNotifications(
                              title: 'SOS', body: 'Someone Needs your help');
                          showPop = true;
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                            ),
                            builder: (_) => RangeSelector(
                              startLoader: (sosRange) async {
                                Navigator.of(_).pop();
                                setState(() {
                                  this.isLoading = true;
                                });
                                UserLocationModel _location =
                                    await LocationService().getLocation();

                                var _address = await Geocoder.local
                                    .findAddressesFromCoordinates(Coordinates(
                                  _location.latitude,
                                  _location.longitude,
                                ));
                                var _first = _address.first;

                                GuestModel _data = new GuestModel(
                                  username: currentUser.username,
                                  gender: currentUser.gender,
                                  uid: currentUser.uid,
                                  name: currentUser.name,
                                  contact: currentUser.contact,
                                  lat: currentUser.lat,
                                  lng: currentUser.lng,
                                  timestamp: DateTime.now(),
                                  address: _first.addressLine,
                                  sosRange: sosRange,
                                );

                                sosRequest = await sendSosAlert(_data);
                                setState(() {
                                  this.isLoading = false;
                                });
                                Navigator.pushNamed(context, '/sender')
                                    .then((value) {
                                  setState(() {
                                    showPop = false;
                                  });
                                  if (value == 'reviewed') {
                                    showFlushBar(
                                      context: context,
                                      title: 'Thanks for your feedback',
                                      message:
                                          'And don\' worry we are always there...',
                                    );
                                  }
                                });
                              },
                            ),
                          );

                          // if (request != null) {
                          //   if (request) {

                          //   }
                          // }
                        },
                        child: Text(
                          "SOS",
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
