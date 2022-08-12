import 'package:flutter/material.dart';
import 'package:humanly/COMPONENTS/Constants.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Function onLongPress;
  const ActionButton({
    Key key,
    this.text,
    this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: this.onPressed,
      onLongPress: this.onLongPress,
      fillColor: kPrimaryColor,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(80.0),
      ),
      child: Container(
        child: Text(
          this.text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
