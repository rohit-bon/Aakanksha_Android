import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/Constants.dart';

// ignore: must_be_immutable
class ReviewTile extends StatelessWidget {
  double rating;
  final String name, contact;
  List<int> indexes = [1, 2, 3, 4, 5];
  ReviewTile({
    Key key,
    this.rating,
    this.name,
    this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rating > 5) {
      rating = 5;
    }
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          // height: 60.0,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 8.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: name == 'YOU' ? kPrimaryColor : Colors.black,
                      ),
                    ),
                    Text(
                      contact,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
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
                          (i > 0 && i <= rating)
                              ? FlutterIcons.star_faw5s
                              : FlutterIcons.star_faw5,
                          color: (i > 0 && i <= rating)
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
      ),
    );
  }
}
