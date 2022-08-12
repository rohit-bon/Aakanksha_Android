import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:humanly/COMPONENTS/ActionButton.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/GuestModel.dart';
import 'package:humanly/MODELS/UserLocationModel.dart';
import 'package:humanly/SERVICES/LocationService.dart';
import 'package:mobile_number/mobile_number.dart';

class DataSelector extends StatefulWidget {
  final List<SimCard> data;
  final Function startLoader;
  final Function endLoader;
  DataSelector({
    Key key,
    this.data,
    @required this.startLoader,
    this.endLoader,
  }) : super(key: key);

  @override
  _DataSelectorState createState() => _DataSelectorState();
}

class _DataSelectorState extends State<DataSelector> {
  String _selected;
  int sosRadius;
  @override
  void initState() {
    _selected = widget.data[0].number;
    sosRadius = 5;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 15.0,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.data
              .map(
                (number) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selected = number.number;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: _selected == number.number
                            ? kPrimaryColor
                            : kPrimaryDarkColor,
                        width: _selected == number.number ? 3.0 : 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        top: 5.0,
                        bottom: 10.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FlutterIcons.sim_card_faw5s,
                            size: 40.0,
                            color: _selected == number.number
                                ? kPrimaryColor
                                : Colors.lightBlue[200],
                          ),
                          SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              '+${number.number}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 10.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20.0,
                child: Text(
                  sosRadius.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbColor: kPrimaryColor,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 12.0,
                    ),
                    overlayColor: kPrimaryColor.withOpacity(0.6),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: 25.0,
                    ),
                    activeTrackColor: kPrimaryColor,
                    inactiveTrackColor: kPrimaryDarkColor,
                  ),
                  child: Slider(
                    value: sosRadius.toDouble(),
                    min: 2.0,
                    max: 25.0,
                    onChanged: (double newValue) {
                      setState(() {
                        sosRadius = newValue.round();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 15.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // GestureDetector(
              //   onTap: () {},
              //   child: Text(
              //     'Enter number manually',
              //     style: TextStyle(
              //       fontSize: 18.0,
              //       fontFamily: 'ProductSans',
              //       decoration: TextDecoration.underline,
              //       decorationColor: kPrimaryColor,
              //       color: kPrimaryColor,
              //     ),
              //   ),
              // ),
              SizedBox(),
              ActionButton(
                text: 'DONE',
                onPressed: () async {
                  Navigator.of(context).pop();
                  this.widget.startLoader();

                  _selected = _selected.substring(
                      (_selected.length - 10), _selected.length);

                  UserLocationModel _location =
                      await LocationService().getLocation();

                  var _address = await Geocoder.local
                      .findAddressesFromCoordinates(Coordinates(
                    _location.latitude,
                    _location.longitude,
                  ));
                  var _first = _address.first;

                  GuestModel _data = new GuestModel(
                    contact: _selected,
                    lat: _location.latitude,
                    lng: _location.longitude,
                    timestamp: DateTime.now(),
                    address: _first.addressLine,
                    sosRange: sosRadius,
                  );

                  sosRequest = await sendSosAlert(_data);

                  this.widget.endLoader();
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
      ],
    );
  }
}
