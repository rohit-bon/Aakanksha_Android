import 'package:flutter/material.dart';
import 'package:humanly/COMPONENTS/Constants.dart';

class OptionButton extends StatelessWidget {
  final IconData icon;
  final String buttonTitle;
  final Function onPressed;
  const OptionButton({
    Key key,
    this.icon,
    this.onPressed,
    this.buttonTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          // backgroundColor: Colors.transparent,
          // elevation: 0.0,
          onTap: this.onPressed,
          child: Icon(
            this.icon,
            color: kPrimaryColor,
            size: 35.0,
          ),
        ),
        SizedBox(height: 5.0),
        Text(
          this.buttonTitle,
          style: TextStyle(
            fontFamily: 'ProductSans',
          ),
        ),
      ],
    );
  }
}
