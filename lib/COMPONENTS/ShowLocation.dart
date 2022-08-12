import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/UserModel.dart';

// ignore: must_be_immutable
class ShowLocation extends StatelessWidget {
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _marker = {};
  CameraPosition _kGooglePlex;

  final UserModel user;
  ShowLocation({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _marker.add(
      Marker(
        markerId: MarkerId('ME'),
        position: LatLng(user.lat, user.lng),
        infoWindow: InfoWindow(
          title: user.name,
          snippet: user.currentArea,
        ),
      ),
    );

    _kGooglePlex = CameraPosition(
      target: LatLng(user.lat, user.lng),
      zoom: 14.4746,
    );
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              mapType: MapType.satellite,
              markers: _marker,
              mapToolbarEnabled: false,
              padding: const EdgeInsets.only(
                top: 90.0,
                left: 10.0,
                right: 10.0,
              ),
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 35.0,
            ),
            child: RawMaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              fillColor: Colors.white,
              elevation: 8.0,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FlutterIcons.arrow_left_faw5s,
                      color: kPrimaryColor,
                      size: 16.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
