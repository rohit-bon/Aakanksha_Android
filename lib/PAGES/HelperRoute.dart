import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:humanly/COMPONENTS/ActionButton.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/GuestModel.dart';
import 'package:humanly/MODELS/UserLocationModel.dart';
import 'package:humanly/SERVICES/LocationService.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

// https://stackoverflow.com/questions/53171531/how-to-add-polyline-on-google-maps-flutter-plugin

const double CAMERA_ZOOM = 20;
const double CAMERA_TILT = 80;
// const double CAMERA_BEARING = 30;

class HelperRoute extends StatelessWidget {
  final GuestModel sos;
  const HelperRoute({Key key, this.sos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocationModel>(
      create: (_) => LocationService().locationStream,
      child: StreamProvider<GuestModel>(
        create: (_) => getSosTrack(sos.id),
        child: Helper(
          sos: this.sos,
        ),
      ),
    );
  }
}

class Helper extends StatefulWidget {
  final GuestModel sos;
  Helper({Key key, this.sos}) : super(key: key);

  @override
  _HelperState createState() => _HelperState();
}

class _HelperState extends State<Helper> {
  // final double CAMERA_BEARING = 30;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers;
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  LocationData destinationLocation;
  PolylinePoints polylinePoints;

  bool refresh = true;
  bool pop = false;

  @override
  void initState() {
    super.initState();
    _markers = {
      Marker(
        markerId: MarkerId('ME'),
        position: LatLng(currentUser.lat, currentUser.lng),
      ),
      Marker(
        markerId: MarkerId('SOS'),
        position: LatLng(widget.sos.lat, widget.sos.lng),
        icon: memberMarker,
        infoWindow: InfoWindow(
          title: widget.sos.name,
          snippet: widget.sos.address,
        ),
      ),
    };
    polylinePoints = PolylinePoints();
    destinationLocation = LocationData.fromMap({
      "latitude": widget.sos.lat,
      "longitude": widget.sos.lat,
    });
  }

  void setPolylines() async {
    var _temp;
    List<PointLatLng> result = [];

    try {
      _temp = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyDQoDrgt_qK-erxn6SRhuHLm69cA-reyEU',
        PointLatLng(currentUser.lat, currentUser.lng),
        PointLatLng(widget.sos.lat, widget.sos.lng),
      );
      result = _temp.points;
    } catch (e) {
      print(e.toString());
    }

    if (result.isNotEmpty) {
      result.forEach((point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      try {
        setState(() {
          _polylines.add(Polyline(
              width: 5, // set the width of the polylines
              polylineId: PolylineId('poly'),
              color: Color.fromARGB(255, 40, 122, 198),
              points: polylineCoordinates));
        });
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void updatePolylines(double lat, double lng) async {
    var _temp;
    List<PointLatLng> result = [];

    try {
      _temp = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyCIWVa5UB0d4DrUkpPUkq5c8KFFawcvBKM',
        PointLatLng(currentUser.lat, currentUser.lng),
        PointLatLng(lat, lng),
      );
      result = _temp.points;
    } catch (e) {
      print(e.toString());
    }

    if (result.isNotEmpty) {
      polylineCoordinates.clear();
      result.forEach((point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      _polylines.removeWhere((element) => element.polylineId.value == 'poly');

      try {
        setState(() {
          _polylines.add(Polyline(
              width: 5, // set the width of the polylines
              polylineId: PolylineId('poly'),
              color: Color.fromARGB(255, 40, 122, 198),
              points: polylineCoordinates));
        });
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Future<void> changeCamera(
      BuildContext context, UserLocationModel location) async {
    if (_controller.isCompleted) {
      GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          // bearing: CAMERA_BEARING,
          // tilt: CAMERA_TILT,
          zoom: 17.5,
        ),
      ));

      var _address, _first;
      try {
        _address =
            await Geocoder.local.findAddressesFromCoordinates(Coordinates(
          location.latitude,
          location.longitude,
        ));
        _first = _address.first;

        try {
          await FirebaseFirestore.instance
              .collection('sosAlert')
              .doc(widget.sos.id)
              .collection('helpers')
              .doc(currentUser.uid)
              .update({
            'lat': location.latitude,
            'lng': location.longitude,
            'location': _first.addressLine,
          });
        } catch (e) {
          print(e.toString());
        }
      } catch (e) {
        print(e.toString());
      }
      _markers.removeWhere((element) => element.markerId.value == 'ME');
      try {
        setState(() {
          currentUser.lat = location.latitude;
          currentUser.lng = location.longitude;
          currentUser.currentArea = _first.addressLine;
          _markers.add(
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
    if (!pop) {
      var _location = Provider.of<UserLocationModel>(context);
      var _sos = Provider.of<GuestModel>(context);

      if (_location != null) {
        if (refresh) {
          changeCamera(context, _location);
          refresh = false;
        }
      }
      if (_sos != null) {
        if (!_sos.resolved) {
          try {
            _markers.removeWhere((element) => element.markerId.value == 'SOS');
          } catch (e) {
            print(e.toString());
          }
          _markers.removeWhere((element) => element.markerId.value == 'SOS');
          try {
            setState(() {
              _markers.add(
                Marker(
                  markerId: MarkerId('SOS'),
                  position: LatLng(_sos.lat, _sos.lng),
                  icon: memberMarker,
                  infoWindow: InfoWindow(
                    title: _sos.name,
                    snippet: _sos.address,
                  ),
                ),
              );
            });
          } catch (e) {
            print(e.toString());
          }
          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId('SOS'),
                position: LatLng(_sos.lat, _sos.lng),
                icon: memberMarker,
                infoWindow: InfoWindow(
                  title: _sos.name,
                  snippet: _sos.address,
                ),
              ),
            );
          });
          updatePolylines(_sos.lat, _sos.lng);
        } else {
          setState(() {
            this.pop = true;
          });
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop('done');
          });
        }
      }
    }
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.satellite,
            markers: _markers,
            mapToolbarEnabled: false,
            compassEnabled: true,
            polylines: _polylines,
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 10.0,
              right: 10.0,
              bottom: 60.0,
            ),
            initialCameraPosition: CameraPosition(
              target: LatLng(currentUser.lat, currentUser.lng),
              // bearing: CAMERA_BEARING,
              tilt: CAMERA_TILT,
              zoom: CAMERA_ZOOM,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              setPolylines();
            },
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      RawMaterialButton(
                        onPressed: () async {
                          try {
                            this.pop = true;

                            Navigator.of(context).pop(widget.sos.id);
                          } catch (e) {
                            print(e.toString());
                            showFlushBar(
                              context: context,
                              title: 'Error Occured!!!',
                              message: 'Failed to terminate',
                            );
                          }
                        },
                        fillColor: Colors.white,
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FlutterIcons.arrow_alt_circle_left_faw5s,
                                color: kPrimaryColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Quit SOS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ),
                Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  child: Container(
                    height: 60.0,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/images/user.png'),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.sos.username,
                                // 'HI',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                ),
                              ),
                              Text(
                                widget.sos.gender,
                                // 'he',
                                style: TextStyle(),
                              ),
                              // Text(
                              //   widget.sos.contact,
                              //   style: TextStyle(),
                              // ),
                            ],
                          ),
                        ),
                        ActionButton(
                          text: 'Call',
                          onPressed: () async {
                            if (await canLaunch('tel:' + widget.sos.contact)) {
                              await launch('tel:' + widget.sos.contact);
                            } else {
                              showFlushBar(
                                context: context,
                                title: 'Unable to launch dialer!',
                                message:
                                    'No supported app found on device, please install one & try again.',
                              );
                            }
                          },
                        ),
                      ],
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

  @override
  void dispose() {
    super.dispose();
    _controller = null;
  }
}
