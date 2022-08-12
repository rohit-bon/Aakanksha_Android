import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/AdminAppDrawer.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/SponsorModel.dart';
import 'package:humanly/PAGES/ADMIN/NewSponsor.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class Sponser extends StatelessWidget {
  const Sponser({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminAppDrawer(
        selectedScreen: '/sponsers',
      ),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 5.0,
        iconTheme: IconTheme.of(context).copyWith(
          color: Colors.white,
        ),
        title: Text(
          'Sponsors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
          ),
        ),
      ),
      body: StreamProvider<List<SponsorModel>>(
        create: (_) => getSponsors(),
        child: SponserBody(),
      ), //HomeBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewSponsor()),
          ).then((value) {
            if (value != null && value) {
              showFlushBar(
                context: context,
                title: 'Done',
                message: 'Sponsor added successfully...',
              );
            }
          });
        },
        backgroundColor: Colors.white,
        child: Icon(
          FlutterIcons.plus_faw5s,
          color: kPrimaryColor,
        ),
      ),
    );
  }
}

class SponserBody extends StatefulWidget {
  SponserBody({Key key}) : super(key: key);

  @override
  _SponserBodyState createState() => _SponserBodyState();
}

class _SponserBodyState extends State<SponserBody> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var _data = Provider.of<List<SponsorModel>>(context);
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      opacity: 0.5,
      progressIndicator: Column(
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
      child: Container(
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
                          builder: (_) => Column(
                            children: [
                              Expanded(
                                child: ListView(
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
                              ),
                              Container(
                                width: double.maxFinite,
                                padding: const EdgeInsets.all(10.0),
                                child: RawMaterialButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  fillColor: Colors.red,
                                  elevation: 8.0,
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      isLoading = true;
                                    });
                                    bool result =
                                        await deleteSponsor(sponsor.id);

                                    if (result) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showFlushBar(
                                        context: context,
                                        title: 'Done',
                                        message:
                                            'Sponsor deleted successfully...',
                                      );
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showFlushBar(
                                        context: context,
                                        title: 'Error Occurred!',
                                        message:
                                            'Sponsor deletion failed, try again...',
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          FlutterIcons.trash_o_faw,
                                          color: Colors.white,
                                          size: 28.0,
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Product Sans',
                                            color: Colors.white,
                                            fontSize: 28.0,
                                          ),
                                        ),
                                      ],
                                    ),
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
      ),
    );
  }
}
