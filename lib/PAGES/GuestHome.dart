import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:humanly/COMPONENTS/ActionButton.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/COMPONENTS/DataSelector.dart';
import 'package:humanly/COMPONENTS/InputField.dart';
import 'package:humanly/COMPONENTS/LogoHeaders.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/SponsorModel.dart';
import 'package:humanly/MODELS/UserModel.dart';
import 'package:humanly/notificationservice.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Guest extends StatelessWidget {
  const Guest({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<SponsorModel>>(
      create: (context) => getSponsors(),
      child: GuestHome(),
    );
  }
}

class GuestHome extends StatefulWidget {
  GuestHome({Key key}) : super(key: key);

  @override
  _GuestHomeState createState() => _GuestHomeState();
}

class _GuestHomeState extends State<GuestHome> {
  @override
  TextEditingController _userId, _password;
  FocusNode _userFocus, _passFocus;
  BuildContext _context;

  bool isLoading;
  bool started;

  double height, width;

  @override
  void initState() {
    _userId = TextEditingController();
    _password = TextEditingController();
    _userFocus = FocusNode();
    _passFocus = FocusNode();

    isLoading = false;
    started = false;
    super.initState();
    tz.initializeTimeZones();
  }

  void selectSosData(List<SimCard> _data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Wrap(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              width: width,
              constraints: BoxConstraints(
                maxHeight: (height / 2),
              ),
              child: DataSelector(
                data: _data,
                startLoader: () {
                  setState(() {
                    isLoading = true;
                  });
                },
                endLoader: () async {
                  setState(() {
                    isLoading = false;
                  });
                  // Navigator.of(context).pop();
                  Navigator.pushNamed(_context, '/sender').then((value) {
                    if (value == 'reviewed') {
                      showFlushBar(
                        context: context,
                        title: 'Thanks for your feedback',
                        message: 'And don\' worry we are always there...',
                      );
                    }
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void sendIosRequest() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Wrap(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              width: width,
              constraints: BoxConstraints(
                maxHeight: (MediaQuery.of(context).size.height / 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 15.0,
                  ),
                  AnimatedPadding(
                    duration: Duration(
                      milliseconds: 150,
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom != 0
                          ? MediaQuery.of(context).viewInsets.bottom - 45
                          : 8,
                    ),
                    child: SizedBox(height: 50.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ActionButton(
                      text: 'DONE',
                      onPressed: () {
                        Navigator.pushNamed(context, '/sender').then((value) {
                          if (value == 'reviewed') {
                            showFlushBar(
                              context: context,
                              title: 'Thanks for your feedback',
                              message: 'And don\' worry we are always there...',
                            );
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    if (!started) {
      height = MediaQuery.of(context).size.height;
      width = MediaQuery.of(context).size.width;
      started = true;
    }
    var _data = Provider.of<List<SponsorModel>>(context);
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: ModalProgressHUD(
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
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: height,
              width: width,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    dragStartBehavior: DragStartBehavior.down,
                    reverse: true,
                    child: Container(
                      height: (height - 30),
                      width: width,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                            ),
                            child: LogoHeaders(),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: double.maxFinite,
                              width: width,
                              child: Center(
                                child: RawMaterialButton(
                                  onPressed: () async {
                                    if (Platform.isAndroid) {
                                      bool hasPermission =
                                          await MobileNumber.hasPhonePermission;
                                      while (!hasPermission) {
                                        await MobileNumber
                                            .requestPhonePermission;
                                        hasPermission = await MobileNumber
                                            .hasPhonePermission;
                                      }
                                      final List<SimCard> simCards =
                                          await MobileNumber.getSimCards;
                                      selectSosData(simCards);
                                    } else {
                                      sendIosRequest();
                                    }
                                  },
                                  fillColor: kPrimaryColor,
                                  elevation: 8.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(80.0),
                                  ),
                                  child: Container(
                                    height: 120,
                                    width: 120,
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Text(
                                        'SOS',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40.0,
                                          color: Colors.white,
                                          fontFamily: 'ProductSans',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Image.asset(
                          //   "assets/images/loc.jpg",
                          //   height: 150,
                          // ),
                          Expanded(
                            child: Container(
                              width: width,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 60.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: width,
                                  ),
                                  InputField(
                                    label: 'User ID',
                                    controller: _userId,
                                    focusNode: _userFocus,
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  InputField(
                                    label: 'Password',
                                    controller: _password,
                                    obscureText: true,
                                    focusNode: _passFocus,
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Login',
                                        style: TextStyle(
                                            fontSize: 27,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: kPrimaryColor,
                                        child: IconButton(
                                            color: Colors.white,
                                            onPressed: () async {
                                              // NotificationService()
                                              //     .showNotification(
                                              //         1, "title", "body", 10);

                                              if (_userId.text != '' &&
                                                  _password.text != '') {
                                                _userFocus.unfocus();
                                                _passFocus.unfocus();
                                                setState(() {
                                                  this.isLoading = true;
                                                });
                                                try {
                                                  QuerySnapshot _data =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'memberDatabase')
                                                          .where('email',
                                                              isEqualTo:
                                                                  _userId.text)
                                                          .where('password',
                                                              isEqualTo:
                                                                  _password
                                                                      .text)
                                                          .get();
                                                  if (_data.docs.length == 1) {
                                                    setState(() {
                                                      this.isLoading = false;
                                                    });
                                                    currentUser =
                                                        UserModel.fromDoc(
                                                            _data.docs.first);
                                                    storeCache(currentUser.uid);
                                                    Navigator.popAndPushNamed(
                                                        context, '/user');
                                                  } else {
                                                    setState(() {
                                                      this.isLoading = false;
                                                    });
                                                    showFlushBar(
                                                      context: context,
                                                      title:
                                                          'Invalid credentials!!!',
                                                      message: 'Try again',
                                                    );
                                                  }
                                                } catch (e) {
                                                  print(e.toString());
                                                  setState(() {
                                                    this.isLoading = false;
                                                  });
                                                  showFlushBar(
                                                    context: context,
                                                    title: 'Error Occured!!!',
                                                    message: 'Try again',
                                                  );
                                                }
                                              }
                                            },
                                            icon: Icon(
                                              Icons.arrow_forward,
                                            )),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ActionButton(
                                        text: 'SIGN UP',
                                        onPressed: () {
                                          _userFocus.unfocus();
                                          _passFocus.unfocus();
                                          if (_userId.text ==
                                                  'admin@humanly.app' &&
                                              _password.text ==
                                                  'adminhumanly') {
                                            Navigator.pushNamed(
                                                context, '/admin');
                                          } else {
                                            Navigator.pushNamed(
                                                    context, '/signup')
                                                .then((value) {
                                              try {
                                                if (value) {
                                                  Navigator.popAndPushNamed(
                                                      context, '/user');
                                                }
                                              } catch (e) {
                                                print(e.toString());
                                              }
                                            });
                                            // Navigator.pushNamed(context, '/user');
                                          }
                                        },
                                      ),
                                      // ActionButton(
                                      //   text: 'LOGIN',
                                      //   onPressed: () async {
                                      //     if (_userId.text != '' &&
                                      //         _password.text != '') {
                                      //       _userFocus.unfocus();
                                      //       _passFocus.unfocus();
                                      //       setState(() {
                                      //         this.isLoading = true;
                                      //       });
                                      //       try {
                                      //         QuerySnapshot _data =
                                      //             await FirebaseFirestore
                                      //                 .instance
                                      //                 .collection(
                                      //                     'memberDatabase')
                                      //                 .where('email',
                                      //                     isEqualTo:
                                      //                         _userId.text)
                                      //                 .where('password',
                                      //                     isEqualTo:
                                      //                         _password.text)
                                      //                 .get();
                                      //         if (_data.docs.length == 1) {
                                      //           setState(() {
                                      //             this.isLoading = false;
                                      //           });
                                      //           currentUser = UserModel.fromDoc(
                                      //               _data.docs.first);
                                      //           storeCache(currentUser.uid);
                                      //           Navigator.popAndPushNamed(
                                      //               context, '/user');
                                      //         } else {
                                      //           setState(() {
                                      //             this.isLoading = false;
                                      //           });
                                      //           showFlushBar(
                                      //             context: context,
                                      //             title:
                                      //                 'Invalid credentials!!!',
                                      //             message: 'Try again',
                                      //           );
                                      //         }
                                      //       } catch (e) {
                                      //         print(e.toString());
                                      //         setState(() {
                                      //           this.isLoading = false;
                                      //         });
                                      //         showFlushBar(
                                      //           context: context,
                                      //           title: 'Error Occured!!!',
                                      //           message: 'Try again',
                                      //         );
                                      //       }
                                      //     }
                                      //   },
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SlidingUpPanel(
                    minHeight: 50.0,
                    maxHeight: (height * 0.9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    panel: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 45.0,
                          width: double.maxFinite,
                          child: Center(
                            child: Text(
                              'Our Sponsors',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 38.0,
                                fontFamily: 'ProductSans',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: width,
                          constraints: BoxConstraints(
                            minHeight: 0.0,
                            maxHeight: (height * 0.8),
                          ),
                          child: GridView.count(
                            primary: false,
                            padding: const EdgeInsets.all(20),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 2,
                            children: _data != null
                                ? _data
                                    .map(
                                      (sponsor) => GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                              ),
                                            ),
                                            context: context,
                                            builder: (_) => Column(
                                              children: [
                                                Expanded(
                                                  child: ListView(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        width: double.maxFinite,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          'Sponsor Detail\'s',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Product Sans',
                                                            fontSize: 35.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        width: double.maxFinite,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          sponsor.sponsorDetail,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Product Sans',
                                                            fontSize: 18.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          sponsor.imageURL,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    )
                                    .toList()
                                : [
                                    SizedBox(),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }
}
