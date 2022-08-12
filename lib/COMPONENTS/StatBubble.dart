import 'package:flutter/material.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/UserModel.dart';
import 'package:provider/provider.dart';

class StatBubble extends StatefulWidget {
  StatBubble({Key key}) : super(key: key);

  @override
  _StatBubbleState createState() => _StatBubbleState();
}

class _StatBubbleState extends State<StatBubble> {
  @override
  Widget build(BuildContext context) {
    var _members = Provider.of<List<UserModel>>(context);
    int _memberCount = 0;
    List<UserModel> _nearBy = [];
    if (_members != null) {
      _members = _members
          .where((element) => (element.uid != currentUser.uid))
          .toList();
      _memberCount = _members.length;
      setState(() {
        _nearBy = _members.where((element) {
          if (element.currentArea == 'NA' ||
              element.currentArea.length < 6 ||
              element.currentArea == null) {
            return false;
          }
          String memeberAreaCode = element.currentArea.substring(
              (element.currentArea.length - 6), element.currentArea.length);

          String userAreaCode = currentUser.currentArea.substring(
              (currentUser.currentArea.length - 6),
              currentUser.currentArea.length);

          return (memeberAreaCode == userAreaCode);
        }).toList();
      });
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamProvider<int>(
          create: (context) => getResolvedCount(),
          child: Column(
            children: [
              SOSCount(),
            ],
          ),
        ),
        Bubble(
          title: 'Members',
          count: _members != null ? _memberCount : 1,
        ),
        Bubble(
          title: 'Nearby',
          count: _nearBy != null ? _nearBy.length : 1,
        ),
        SizedBox(width: 14.0),
      ],
    );
  }
}

class SOSCount extends StatefulWidget {
  SOSCount({Key key}) : super(key: key);

  @override
  _SOSCountState createState() => _SOSCountState();
}

class _SOSCountState extends State<SOSCount> {
  @override
  Widget build(BuildContext context) {
    var _data = Provider.of<int>(context);
    return Bubble(
      title: 'Resolved',
      count: _data != null ? _data : 1,
    );
  }
}

class Bubble extends StatelessWidget {
  final String title;
  final int count;
  const Bubble({Key key, this.title, this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 5.0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: kPrimaryColor,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Text(
        '$title: $count',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'ProductSans',
          fontWeight: FontWeight.bold,
          // fontSize: 16.0,
        ),
      ),
    );
  }
}
