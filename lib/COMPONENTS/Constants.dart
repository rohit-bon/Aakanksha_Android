import 'dart:math' show sin, cos, sqrt, atan2;
import 'package:vector_math/vector_math.dart' as vm;
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:humanly/MODELS/GuestModel.dart';
import 'package:humanly/MODELS/UserModel.dart';

const Color kPrimaryColor = Color(0xFFFC8019);
const Color kPrimaryDarkColor = Color(0xFFAEAFAB);
const Color kBorderColor = Color.fromARGB(255, 6, 7, 6);

UserModel currentUser;
BitmapDescriptor memberMarker;
GuestModel sosRequest;

double calculateDistance(double lat, double lng) {
  double earthRadius = 6371000;

  var latDiff = vm.radians(lat - currentUser.lat);
  var lngDiff = vm.radians(lng - currentUser.lng);

  var approx = sin(latDiff / 2) * sin(latDiff / 2) +
      cos(vm.radians(currentUser.lat)) *
          cos(vm.radians(lat)) *
          sin(lngDiff / 2) *
          sin(lngDiff / 2);

  var canoDiff = 2 * atan2(sqrt(approx), sqrt(1 - approx));
  var _return = earthRadius * canoDiff;

  _return = (_return + (_return * 0.25));

  return (_return / 1000);
}

void showFlushBar(
    {BuildContext context,
    String title,
    String message = 'Check your network connection OR try again! '}) {
  Flushbar(
    margin: EdgeInsets.all(10.0),
    padding: EdgeInsets.all(10.0),
    // borderRadius: 8.0,
    boxShadows: [
      BoxShadow(
        color: Colors.black45,
        offset: Offset(3, 3),
        blurRadius: 4,
      ),
    ],
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    duration: Duration(seconds: 4),
    titleText: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
        fontFamily: 'ProductSans',
        color: Colors.white,
        letterSpacing: 0.7,
      ),
    ),
    messageText: Text(
      message,
      style: TextStyle(
        fontFamily: 'ProductSans',
        color: Colors.white,
      ),
    ),
  )..show(context);
}
