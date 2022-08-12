import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/AdminAppDrawer.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminAppDrawer(
        selectedScreen: '/admin',
      ),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 5.0,
        iconTheme: IconTheme.of(context).copyWith(
          color: Colors.white,
        ),
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
          ),
        ),
      ),
      body: HomeBody(),
    );
  }
}

class HomeBody extends StatefulWidget {
  HomeBody({Key key}) : super(key: key);

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
          future: getDataCounts(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.none || !snap.hasData) {
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                  ),
                ),
              );
            } else {
              List<Map<String, dynamic>> _data = [
                {
                  'icon': FlutterIcons.users_faw5s,
                  'title': 'Our Members\'',
                  'count': snap.data['members'],
                  'route': '/members',
                },
                {
                  'icon': FlutterIcons.md_medical_ion,
                  'title': 'SOS Alerts\'',
                  'count': snap.data['sosAlerts'],
                  'route': '/sosStats',
                },
                {
                  'icon': FlutterIcons.rupee_sign_faw5s,
                  'title': 'Sponsers\'',
                  'count': snap.data['sponsers'],
                  'route': '/sponsers',
                },
              ];
              return ListView(
                children: _data
                    .map(
                      (e) => InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, e['route']);
                        },
                        child: InfoTile(
                          icon: e['icon'],
                          title: e['title'],
                          count: e['count'],
                        ),
                      ),
                    )
                    .toList(),
              );
            }
          }),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  const InfoTile({Key key, this.icon, this.title, this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(3.0),
        elevation: 5.0,
        child: Container(
          width: double.maxFinite,
          height: 140,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  this.icon,
                  color: kPrimaryColor,
                  size: 72,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        this.title,
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      Text(
                        this.count.toString(),
                        style: TextStyle(
                          fontSize: 65,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 15.0),
            ],
          ),
        ),
      ),
    );
  }
}
