import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key key}) : super(key: key);

  Future<void> preprocessor(BuildContext context) async {
    final SharedPreferences _cache = await SharedPreferences.getInstance();
    try {
      ImageConfiguration config = createLocalImageConfiguration(
        context,
      );

      memberMarker = await BitmapDescriptor.fromAssetImage(
          config, 'assets/images/memberMarker.png');

      if (_cache.getBool('isLoggedIn')) {
        String _userID = _cache.getString('uid');
        DocumentSnapshot _data = await FirebaseFirestore.instance
            .collection('memberDatabase')
            .doc(_userID)
            .get();

        currentUser = UserModel.fromDoc(_data);
        Future.delayed(Duration(seconds: 4), () {
          Navigator.popAndPushNamed(context, '/user');
        });
      } else {
        Future.delayed(Duration(seconds: 4), () {
          Navigator.popAndPushNamed(context, '/guest');
        });
      }
    } catch (e) {
      print(e.toString());
      Future.delayed(Duration(seconds: 4), () {
        Navigator.popAndPushNamed(context, '/guest');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    preprocessor(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: double.maxFinite,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
