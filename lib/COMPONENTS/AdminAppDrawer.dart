import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/Constants.dart';

class AdminAppDrawer extends StatelessWidget {
  final List<NavItem> nav = [
    NavItem(
      icon: FlutterIcons.dashboard_faw,
      title: 'Dashboard',
      route: '/admin',
    ),
    NavItem(
      icon: FlutterIcons.users_faw5s,
      title: 'Members',
      route: '/members',
    ),
    NavItem(
      icon: FlutterIcons.md_analytics_ion,
      title: 'Leader Board',
      route: '/leaderboard',
    ),
    NavItem(
      icon: FlutterIcons.md_medical_ion,
      title: 'SOS Alerts',
      route: '/sosStats',
    ),
    NavItem(
      icon: FlutterIcons.rupee_sign_faw5s,
      title: 'Sponser Management',
      route: '/sponsers',
    ),
  ];

  final String selectedScreen;
  AdminAppDrawer({
    Key key,
    this.selectedScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: (MediaQuery.of(context).size.width * 0.75),
      child: Column(
        children: [
          SizedBox(
            height: 30.0,
          ),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/images/user.png'),
                  radius: 40.0,
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    'Humanly Admin',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 40.0,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: nav
                  .map(
                    (item) => ListTile(
                      leading: Icon(
                        item.icon,
                        color: item.route == selectedScreen
                            ? kPrimaryColor
                            : kPrimaryDarkColor,
                        size: item.route == selectedScreen ? 28 : 24,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontWeight: item.route == selectedScreen
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: item.route == selectedScreen
                              ? kPrimaryColor
                              : kPrimaryDarkColor,
                          fontSize: item.route == selectedScreen ? 20 : 16,
                        ),
                      ),
                      onTap: () {
                        try {
                          Navigator.pop(context);
                          Navigator.popAndPushNamed(context, item.route);
                        } catch (e) {
                          print(e.toString());
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  String route;
  String title;
  IconData icon;

  NavItem({
    this.route,
    this.title,
    this.icon,
  });
}
