import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/UserModel.dart';
import 'package:provider/provider.dart';

class MemberTracker extends StatelessWidget {
  final UserModel user;
  const MemberTracker({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: StreamProvider<UserModel>(
              create: (_) => getMember(this.user.uid),
              child: MemberTrackerBody(user: this.user),
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

class MemberTrackerBody extends StatefulWidget {
  final UserModel user;
  MemberTrackerBody({Key key, this.user}) : super(key: key);

  @override
  _MemberTrackerBodyState createState() => _MemberTrackerBodyState();
}

class _MemberTrackerBodyState extends State<MemberTrackerBody> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marker = {};

  CameraPosition _kGooglePlex;

  Future<void> changeCamera(LatLng loc) async {
    if (_controller.isCompleted) {
      GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(loc.latitude, loc.longitude),
          // tilt: 35.440717697143555,
          zoom: 15.851926040649414,
        ),
      ));
    }
  }

  @override
  void initState() {
    _marker.add(
      Marker(
        markerId: MarkerId('ME'),
        position: LatLng(widget.user.lat, widget.user.lng),
        infoWindow: InfoWindow(
          title: widget.user.name,
          snippet: widget.user.currentArea,
        ),
      ),
    );

    _kGooglePlex = CameraPosition(
      target: LatLng(widget.user.lat, widget.user.lng),
      zoom: 14.4746,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _data = Provider.of<UserModel>(context);

    if (_data != null) {
      _marker.removeWhere((element) => element.markerId.value == 'ME');

      _marker.add(
        Marker(
          markerId: MarkerId('ME'),
          position: LatLng(_data.lat, _data.lng),
          infoWindow: InfoWindow(
            title: _data.name,
            snippet: _data.currentArea,
          ),
        ),
      );

      changeCamera(LatLng(_data.lat, _data.lng));
    }
    return GoogleMap(
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
    );
  }
}
