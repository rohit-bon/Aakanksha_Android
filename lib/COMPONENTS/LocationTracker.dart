import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/UserLocationModel.dart';
import 'package:humanly/MODELS/UserModel.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class LocationTracker extends StatefulWidget {
  LocationTracker({Key key}) : super(key: key);

  @override
  _LocationTrackerState createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marker = {
    Marker(
      markerId: MarkerId('ME'),
      position: LatLng(currentUser.lat, currentUser.lng),
    ),
  };
  bool refresh = true;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(currentUser.lat, currentUser.lng),
    zoom: 14.4746,
  );

  Future<void> changeCamera(
      BuildContext context, UserLocationModel location) async {
    if (_controller.isCompleted) {
      GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(location.latitude, location.longitude),
          // tilt: 35.440717697143555,
          zoom: 15.851926040649414,
        ),
      ));

      try {
        var _address =
            await Geocoder.local.findAddressesFromCoordinates(Coordinates(
          location.latitude,
          location.longitude,
        ));
        var _first = _address.first;
        //
        // print(_first.addressLine);
        // showFlushBar(
        //   context: context,
        //   title: 'Locality: ${_first.locality}, ${_first.subLocality}',
        //   message: 'Code: ${_first.postalCode}',
        // );

        await FirebaseFirestore.instance
            .collection('memberDatabase')
            .doc(currentUser.uid)
            .update({
          'lat': location.latitude,
          'lng': location.longitude,
          'currentArea':
              '${_first.subLocality}, ${_first.locality}, ${_first.postalCode}',
        });
        _marker.removeWhere((element) => element.markerId.value == 'ME');
        setState(() {
          currentUser.lat = location.latitude;
          currentUser.lng = location.longitude;
          currentUser.currentArea =
              '${_first.subLocality}, ${_first.locality}, ${_first.postalCode}';
          _marker.add(
            Marker(
              markerId: MarkerId('ME'),
              position: LatLng(location.latitude, location.longitude),
            ),
          );
        });
      } catch (e) {
        print(e.toString());
      }

      await Future.delayed(Duration(
        milliseconds: 500,
      ));
      refresh = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var _location = Provider.of<UserLocationModel>(context);
    var _members = Provider.of<List<UserModel>>(context);

    if (_location != null) {
      if (refresh) {
        changeCamera(context, _location);
        refresh = false;
      }
    }

    if (_members != null) {
      _members = _members.where((element) {
        bool uidMatch = element.uid != currentUser.uid;

        if (element.currentArea == 'NA' || element.currentArea.length < 6) {
          return false;
        }
        String memeberAreaCode = element.currentArea.substring(
            (element.currentArea.length - 6), element.currentArea.length);

        String userAreaCode = currentUser.currentArea.substring(
            (currentUser.currentArea.length - 6),
            currentUser.currentArea.length);

        return ((memeberAreaCode == userAreaCode) && uidMatch);
      }).toList();

      _marker.removeWhere((element) => element.markerId.value != 'ME');

      setState(() {
        _members.forEach((element) {
          _marker.add(
            Marker(
              markerId: MarkerId(element.uid),
              position: LatLng(element.lat, element.lng),
              icon: memberMarker,
              infoWindow: InfoWindow(
                title: element.name,
                snippet: element.currentArea,
              ),
            ),
          );
        });
      });
    }

    return GoogleMap(
      mapType: MapType.satellite,
      markers: _marker,
      mapToolbarEnabled: false,
      padding: const EdgeInsets.only(
        top: 90.0,
        left: 10.0,
        right: 10.0,
        bottom: 60.0,
      ),
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}
