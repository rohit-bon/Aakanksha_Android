import 'package:flutter/material.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/SponsorModel.dart';
import 'package:provider/provider.dart';

class UserSponser extends StatelessWidget {
  const UserSponser({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 5.0,
        iconTheme: IconTheme.of(context).copyWith(
          color: Colors.white,
        ),
        title: Text(
          'Our Sponsers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
          ),
        ),
      ),
      body: StreamProvider<List<SponsorModel>>(
        create: (_) => getSponsors(),
        child: UserSponserHome(),
      ), //HomeB
    );
  }
}

class UserSponserHome extends StatefulWidget {
  UserSponserHome({Key key}) : super(key: key);

  @override
  _UserSponserHomeState createState() => _UserSponserHomeState();
}

class _UserSponserHomeState extends State<UserSponserHome> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var _data = Provider.of<List<SponsorModel>>(context);
    if (_data != null) {
      if (_data.length > 0) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: _data != null
                ? _data
                    .map(
                      (sponsor) => GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                            ),
                            context: context,
                            builder: (_) => ListView(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  width: double.maxFinite,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Sponsor Detail\'s',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Product Sans',
                                      fontSize: 35.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  width: double.maxFinite,
                                  alignment: Alignment.center,
                                  child: Text(
                                    sponsor.sponsorDetail,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Product Sans',
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Image.network(
                          sponsor.imageURL,
                          fit: BoxFit.fill,
                        ),
                      ),
                    )
                    .toList()
                : [
                    SizedBox(),
                  ],
          ),
        );
      } else {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Text('no sponser found!!!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                )),
          ),
        );
      }
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kPrimaryColor),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Please Wait...',
              ),
            ],
          ),
        ),
      );
    }
  }
}
