import 'package:flutter/material.dart';
import 'package:humanly/COMPONENTS/ActionButton.dart';
import 'package:humanly/COMPONENTS/Constants.dart';

class RangeSelector extends StatefulWidget {
  final Function startLoader;
  RangeSelector({
    Key key,
    this.startLoader,
  }) : super(key: key);

  @override
  _RangeSelectorState createState() => _RangeSelectorState();
}

class _RangeSelectorState extends State<RangeSelector> {
  int sosRadius;
  double height, width;

  @override
  void initState() {
    super.initState();
    sosRadius = 5;
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          width: width,
          // constraints: BoxConstraints(
          //   maxHeight: (height / 2),
          // ),
          child: Column(
            children: [
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
                          fontSize: 15.0,
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
                    SizedBox(),
                    ActionButton(
                      text: 'DONE',
                      onPressed: () async {
                        widget.startLoader(sosRadius);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }
}
