import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/COMPONENTS/HelperTile.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/HelperModel.dart';
import 'package:humanly/MODELS/UserLocationModel.dart';
import 'package:humanly/SERVICES/LocationService.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:another_flushbar/flushbar.dart';

class SosSenderScreen extends StatelessWidget {
  const SosSenderScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocationModel>(
      create: (_) => LocationService().locationStream,
      child: StreamProvider<List<HelperModel>>(
        create: (_) => getHelpers(),
        child: SosSender(),
      ),
    );
  }
}

class SosSender extends StatefulWidget {
  SosSender({Key key}) : super(key: key);

  @override
  _SosSenderState createState() => _SosSenderState();
}

class _SosSenderState extends State<SosSender> {
  Completer<GoogleMapController> _controller = Completer();
  PanelController _panel = PanelController();
  Set<Marker> _marker;
  bool refresh = true;
  bool pop = false;
  bool review = false;
  Map<String, int> ratings = {};

  @override
  void initState() {
    super.initState();
    _marker = {
      Marker(
        markerId: MarkerId('ME'),
        position: LatLng(sosRequest.lat, sosRequest.lng),
      ),
    };
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(sosRequest.lat, sosRequest.lng),
    zoom: 14.4746,
  );

  Future<void> changeCamera(UserLocationModel location) async {
    if (_controller.isCompleted) {
      GoogleMapController controller = await _controller.future;
      try {
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 192.8334901395799,
            target: LatLng(location.latitude, location.longitude),
            // tilt: 35.440717697143555,
            zoom: 17.4746,
          ),
        ));
      } catch (e) {
        print(e.toString());
      }

      var _address =
          await Geocoder.local.findAddressesFromCoordinates(Coordinates(
        location.latitude,
        location.longitude,
      ));
      var _first = _address.first;

      try {
        await FirebaseFirestore.instance
            .collection('sosAlert')
            .doc(sosRequest.id)
            .update({
          'lat': location.latitude,
          'lng': location.longitude,
          'address': _first.addressLine,
        });
      } catch (e) {
        print(e.toString());
      }

      _marker.removeWhere((element) => element.markerId.value == 'ME');
      try {
        setState(() {
          sosRequest.lat = location.latitude;
          sosRequest.lng = location.longitude;
          sosRequest.address = _first.addressLine;
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
    var _data = Provider.of<List<HelperModel>>(context);

    if (_location != null) {
      if (refresh) {
        changeCamera(_location);
        refresh = false;
      }
    }

    if (_data != null && _data.length > 0) {
      _marker.removeWhere((element) => element.markerId.value != 'ME');
      _data.forEach((element) {
        setState(() {
          _marker.add(
            Marker(
              markerId: MarkerId(element.id),
              position: LatLng(element.lat, element.lng),
              icon: memberMarker,
              infoWindow: InfoWindow(
                title: element.name,
                snippet: element.location,
              ),
            ),
          );
        });
      });
    } else if (_data != null && _data.length <= 0) {
      setState(() {
        _marker.removeWhere((element) => element.markerId.value != 'ME');
      });
    }

    if (_data != null) {
      if (ratings.length != _data.length) {
        _data.forEach((element) {
          ratings.putIfAbsent(element.id, () => 0);
        });
      }
    }
    return WillPopScope(
      onWillPop: () async {
        return this.pop;
      },
      child: Scaffold(
        backgroundColor: kPrimaryDarkColor,
        body: Stack(
          children: [
            // SosLiveTracker(),
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                mapType: MapType.satellite,
                markers: _marker,
                mapToolbarEnabled: false,
                padding: EdgeInsets.only(
                  top: 20.0,
                  left: 10.0,
                  right: 10.0,
                  bottom: 61.0,
                ),
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    width: MediaQuery.of(context).size.width,
                    child: RawMaterialButton(
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('sosAlert')
                              .doc(sosRequest.id)
                              .update({
                            'resolved': true,
                          });
                          if (_data != null) {
                            if (_data.length == 0) {
                              this.pop = true;
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                review = true;
                              });
                              _panel.open();
                            }
                          } else {
                            setState(() {
                              review = true;
                            });
                            _panel.open();
                          }
                        } catch (e) {
                          print(e.toString());
                          showFlushBar(
                            context: context,
                            title: 'Error Occured!!!',
                            message: 'Failed to terminate',
                          );
                        }
                      },
                      fillColor: kPrimaryColor,
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          'DISABLE SOS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 0,
                  ),
                ],
              ),
            ),
            SlidingUpPanel(
              controller: _panel,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              minHeight: 60.0,
              maxHeight: (MediaQuery.of(context).size.height * 0.9),
              panel: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 60.0,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        _data == null
                            ? 'waiting for helpers....'
                            : (review
                                ? 'Your helpers\' would like some feedback :)'
                                : '${_data.length} Helpers\' on the way...'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: _data
                          .map((helper) => GestureDetector(
                                onTap: () async {
                                  Dio dio = new Dio();
                                  Response response = await dio.get(
                                      "https://maps.google.com/maps/distancematrix/json?units=imperial&origins=${sosRequest.lat},${sosRequest.lng}8&destinations=${helper.lat}%2C,${helper.lat}&key=AIzaSyCIWVa5UB0d4DrUkpPUkq5c8KFFawcvBKM");
                                  print(response.data);
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
                                    dismissDirection:
                                        FlushbarDismissDirection.HORIZONTAL,
                                    forwardAnimationCurve:
                                        Curves.fastLinearToSlowEaseIn,
                                    duration: Duration(minutes: 5),
                                    flushbarPosition: FlushbarPosition.TOP,
                                    titleText: Text(
                                      'Estimated Time of Arrival',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        fontFamily: 'ProductSans',
                                        color: Colors.white,
                                        letterSpacing: 0.7,
                                      ),
                                    ),
                                    messageText: Text(
                                      '${response.data} Minutes',
                                      style: TextStyle(
                                        fontFamily: 'ProductSans',
                                        color: Colors.white,
                                      ),
                                    ),
                                  )..show(context);
                                },
                                child: HelperTile(
                                  data: helper,
                                  review: this.review,
                                  onFeed: (int rating) {
                                    ratings.update(
                                        helper.id, (value) => rating);
                                    print(ratings);
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  Visibility(
                    visible: this.review,
                    child: Container(
                      height: 60.0,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RawMaterialButton(
                            onPressed: () async {
                              bool rs = await updateNoRatings(_data);
                              if (rs) {
                                Navigator.of(context).pop();
                              } else {
                                showFlushBar(
                                  context: context,
                                  title: 'Error Occured!!!',
                                  message: 'Failed, retry again...',
                                );
                              }
                            },
                            fillColor: kPrimaryColor,
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'CANCEL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          RawMaterialButton(
                            onPressed: () async {
                              bool bs = await updateRatings(ratings);
                              if (bs) {
                                Navigator.of(context).pop('reviewed');
                              } else {
                                showFlushBar(
                                  context: context,
                                  title: 'Error Occured!!!',
                                  message: 'Failed, retry again...',
                                );
                              }
                            },
                            fillColor: kPrimaryColor,
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'SUBMIT',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller = null;
  }
}
