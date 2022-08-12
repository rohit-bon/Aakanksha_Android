import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/DrawerTileModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatelessWidget {
  final List<DrawerTileModel> _data = [
    DrawerTileModel(
      title: 'Your Profile',
      icon: FlutterIcons.user_faw5s,
      route: '/profile',
    ),
    DrawerTileModel(
      title: 'My Reviews',
      icon: FlutterIcons.star_faw5,
      route: '/myReview',
    ),
    DrawerTileModel(
      title: 'Leaderboard',
      icon: FlutterIcons.graph_bar_fou,
      route: '/leaderboard',
    ),
    DrawerTileModel(
      title: 'Our Sponsers',
      icon: FlutterIcons.rupee_sign_faw5s,
      route: '/sponser',
    ),
    DrawerTileModel(
      title: 'About Us',
      icon: FlutterIcons.info_circle_faw5s,
      route: '/profile',
    ),
    DrawerTileModel(
      title: 'Family Member',
      icon: FlutterIcons.group_faw,
      route: '/searchmem',
    )
  ];
  AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: (MediaQuery.of(context).size.width * 0.75),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 45.0,
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: double.maxFinite,
              fit: BoxFit.fitWidth,
            ),
          ),
          Expanded(
            child: ListView(
              children: _data
                  .map(
                    (option) => ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, option.route);
                      },
                      leading: Icon(
                        option.icon,
                        color: kPrimaryColor,
                      ),
                      title: Text(
                        option.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Container(
            width: double.maxFinite,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 20.0,
            ),
            child: RawMaterialButton(
              onPressed: () async {
                final SharedPreferences _cache =
                    await SharedPreferences.getInstance();

                _cache.clear();
                currentUser = null;
                Navigator.of(context).pop();
                Navigator.of(context).popAndPushNamed('/guest');
              },
              fillColor: kPrimaryColor,
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 15.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LOGOUT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      FlutterIcons.log_out_fea,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
