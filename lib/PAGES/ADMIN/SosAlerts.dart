import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/AdminAppDrawer.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/GuestModel.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/PAGES/ADMIN/SosInfo.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SosAlerts extends StatelessWidget {
  const SosAlerts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminAppDrawer(
        selectedScreen: '/sosStats',
      ),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 5.0,
        iconTheme: IconTheme.of(context).copyWith(
          color: Colors.white,
        ),
        title: Text(
          'SOS Alert\'s',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
          ),
        ),
      ),
      body: StreamProvider<List<GuestModel>>(
        create: (_) => getSosAlert(),
        child: SosAlertsBody(),
      ), //HomeBody(),
    );
  }
}

class SosAlertsBody extends StatefulWidget {
  SosAlertsBody({Key key}) : super(key: key);

  @override
  _SosAlertsBodyState createState() => _SosAlertsBodyState();
}

class _SosAlertsBodyState extends State<SosAlertsBody> {
  @override
  Widget build(BuildContext context) {
    List<GuestModel> _data = Provider.of<List<GuestModel>>(context);
    if (_data == null) {
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
      if (_data.length == 0) {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Text(
              'no data found...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Product Sans',
              ),
            ),
          ),
        );
      }
      return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      _data[index].resolved
                          ? FlutterIcons.check_circle_faw5s
                          : FlutterIcons.close_circle_mco,
                      size: _data[index].resolved ? 36 : 40,
                      color: _data[index].resolved
                          ? Colors.green[300]
                          : Colors.red[300],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Text(
                            _data[index].name,
                            maxLines: 2,
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          child: Text(
                            DateFormat('EEE, dd MMM yyyy, HH:mm')
                                .format(_data[index].timestamp.toDate()),
                            maxLines: 2,
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_data[index].sosRange} KM\'s',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      fontFamily: 'Product Sans',
                    ),
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        FlutterIcons.eye_faw5,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SosInfo(sos: _data[index]),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: _data.length,
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Divider(
              thickness: 0.5,
            ),
          );
        },
      );
    }
  }
}
