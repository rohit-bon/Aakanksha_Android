import 'package:flutter/material.dart';
import 'package:humanly/COMPONENTS/Constants.dart';

class ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onTap;
  final Function onLongPressed;
  const ProfileActionButton({
    Key key,
    this.icon,
    this.title,
    this.onTap,
    this.onLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      fillColor: kPrimaryColor,
      elevation: 8.0,
      onPressed: this.onTap,
      onLongPress: this.onLongPressed,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              this.icon,
              color: Colors.white,
              size: 16.0,
            ),
            SizedBox(width: 8.0),
            Text(
              this.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
