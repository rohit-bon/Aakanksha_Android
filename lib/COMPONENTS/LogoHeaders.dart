import 'package:flutter/material.dart';

class LogoHeaders extends StatelessWidget {
  const LogoHeaders({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 40,
          child: Image.asset(
            'assets/images/mii.png',
            fit: BoxFit.fitHeight,
          ),
        ),
        SizedBox(
          height: 40,
          child: Image.asset(
            'assets/images/di.png',
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }
}
