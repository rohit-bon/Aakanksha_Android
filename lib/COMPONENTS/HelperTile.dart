import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/ActionButton.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/HelperModel.dart';
import 'package:url_launcher/url_launcher.dart';

class HelperTile extends StatelessWidget {
  final HelperModel data;
  final bool review;
  final Function onFeed;
  const HelperTile({
    Key key,
    this.data,
    this.review,
    this.onFeed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  data.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  ),
                ),
                // Text(
                //   data.contact,
                //   style: TextStyle(),
                // ),
              ],
            ),
          ),
          HelperActions(
            contact: data.contact,
            reviewed: review,
            onFeed: this.onFeed,
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class HelperActions extends StatefulWidget {
  String contact;
  bool reviewed;
  Function onFeed;
  HelperActions({
    Key key,
    this.contact,
    this.reviewed,
    this.onFeed,
  }) : super(key: key);

  @override
  _HelperActionsState createState() => _HelperActionsState();
}

class _HelperActionsState extends State<HelperActions> {
  List<int> indexes = [0, 1, 2, 3, 4];
  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    if (widget.reviewed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: indexes
            .map(
              (e) => GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = indexes.indexOf(e);
                  });
                  widget.onFeed(selectedIndex + 1);
                },
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Icon(
                    (indexes.indexOf(e) >= 0 &&
                            indexes.indexOf(e) <= selectedIndex)
                        ? FlutterIcons.star_faw5s
                        : FlutterIcons.star_faw5,
                    color: (indexes.indexOf(e) >= 0 &&
                            indexes.indexOf(e) <= selectedIndex)
                        ? Colors.yellow[300]
                        : Colors.black,
                  ),
                ),
              ),
            )
            .toList(),
      );
    } else {
      return ActionButton(
        text: 'Call',
        onPressed: () async {
          if (await canLaunch('tel:' + widget.contact)) {
            await launch('tel:' + widget.contact);
          } else {
            showFlushBar(
              context: context,
              title: 'Unable to launch dialer!',
              message:
                  'No supported app found on device, please install one & try again.',
            );
          }
        },
      );
    }
  }
}
