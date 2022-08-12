import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:humanly/COMPONENTS/ActionButton.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/GuestModel.dart';
import 'package:humanly/MODELS/HelperModel.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class SosInfo extends StatefulWidget {
  final GuestModel sos;
  SosInfo({
    Key key,
    this.sos,
  }) : super(key: key);

  @override
  _SosInfoState createState() => _SosInfoState();
}

class _SosInfoState extends State<SosInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: IconTheme.of(context).copyWith(
          color: Colors.white,
        ),
        title: Text(
          'SOS Alert Info',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SosInfoBody(sos: this.widget.sos),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Change SOS Status',
        onPressed: () {
          updateSosStatus(widget.sos.id, !widget.sos.resolved).then((value) {
            if (value) {
              showFlushBar(
                context: context,
                title: 'Status Updated...',
                message: 'Status Changes Successfully',
              );
              setState(() {
                widget.sos.resolved = !widget.sos.resolved;
              });
            } else {
              showFlushBar(
                context: context,
                title: 'Error Occured...',
                message: 'Please try again after sometimes!!!',
              );
            }
          });
        },
        backgroundColor:
            widget.sos.resolved ? Colors.red[300] : Colors.green[300],
        child: Icon(
          FlutterIcons.refresh_faw,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SosInfoBody extends StatefulWidget {
  final GuestModel sos;
  SosInfoBody({
    Key key,
    this.sos,
  }) : super(key: key);

  @override
  _SosInfoBodyState createState() => _SosInfoBodyState();
}

class _SosInfoBodyState extends State<SosInfoBody> {
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _marker;
  CameraPosition _kGooglePlex;

  @override
  void initState() {
    _marker = {
      Marker(
        markerId: MarkerId('SOS'),
        position: LatLng(widget.sos.lat, widget.sos.lng),
        infoWindow: InfoWindow(
          title: widget.sos.name,
          snippet: widget.sos.address,
        ),
      ),
    };

    _kGooglePlex = CameraPosition(
      target: LatLng(widget.sos.lat, widget.sos.lng),
      zoom: 14.4746,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getHelpersList(widget.sos.id),
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
          List<HelperModel> _data;
          List<Widget> _listItems = [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'RANGED',
                              style: TextStyle(
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.sos.sosRange.toString(),
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 27.0,
                              ),
                            ),
                            Text(
                              'K M S\'',
                              style: TextStyle(
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.maxFinite,
                              child: Text(
                                widget.sos.name,
                                style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.maxFinite,
                              child: Text(
                                DateFormat('EEE, dd/MMM/yyyy @ HH:mm')
                                    .format(widget.sos.timestamp.toDate()),
                                style: TextStyle(
                                  fontFamily: 'ProductSans',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ActionButton(
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
                          onLongPress: () {
                            showModalBottomSheet(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                ),
                              ),
                              context: context,
                              builder: (_) => Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  widget.sos.contact,
                                  style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.maxFinite,
              child: Center(
                child: Text(
                  'HELPER\'S',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
          ];
          if (snap != null && snap.data.length > 0) {
            List<int> indexes = [1, 2, 3, 4, 5];
            _data = snap.data;

            _data.forEach((e) {
              _marker.add(
                Marker(
                  markerId: MarkerId('Helper'),
                  position: LatLng(e.lat, e.lng),
                  infoWindow: InfoWindow(
                    title: e.name,
                    snippet: e.location,
                  ),
                ),
              );

              _listItems.add(
                Container(
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
                              e.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            Text(
                              e.contact,
                              style: TextStyle(),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: indexes
                            .map(
                              (i) => Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Icon(
                                  (i > 0 && i <= e.rating)
                                      ? FlutterIcons.star_faw5s
                                      : FlutterIcons.star_faw5,
                                  color: (i > 0 && i <= e.rating)
                                      ? Colors.yellow[300]
                                      : Colors.black,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              );
            });
          } else if (snap != null && snap.data.length == 0) {
            _listItems.add(
              Container(
                height: 60.0,
                width: double.maxFinite,
                child: Center(
                  child: Text(
                    'No helper arrived!',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            );
          }
          return SlidingUpPanel(
            minHeight: (MediaQuery.of(context).size.height * 0.21),
            maxHeight: (MediaQuery.of(context).size.height * 0.80),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
            panel: Column(
              children: [
                SizedBox(
                  height: 20.0,
                  width: double.maxFinite,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      width: 40.0,
                      height: 5.0,
                    ),
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  child: Material(
                    elevation: 5.0,
                    color: widget.sos.resolved ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(30.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 35.0,
                      ),
                      child: Text(
                        widget.sos.resolved ? 'RESOLVED' : 'UNRESOLVED',
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 25.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: ListView(
                      children: _listItems,
                    ),
                  ),
                ),
              ],
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: GoogleMap(
                mapType: MapType.satellite,
                markers: _marker,
                mapToolbarEnabled: false,
                padding: EdgeInsets.only(
                  top: 100.0,
                  left: 10.0,
                  right: 10.0,
                  bottom: ((MediaQuery.of(context).size.height * 0.22) + 75),
                ),
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
          );
        }
      },
    );
  }
}
