import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/AdminAppDrawer.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/UserModel.dart';
import 'package:humanly/PAGES/ADMIN/MemberProfile.dart';
import 'package:provider/provider.dart';

class Members extends StatelessWidget {
  const Members({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminAppDrawer(
        selectedScreen: '/members',
      ),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 5.0,
        iconTheme: IconTheme.of(context).copyWith(
          color: Colors.white,
        ),
        title: Text(
          'Members',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
          ),
        ),
      ),
      body: StreamProvider<List<UserModel>>(
        create: (_) => getMembersData(),
        child: MemberBody(),
      ), //HomeBody(),
    );
  }
}

class MemberBody extends StatefulWidget {
  MemberBody({Key key}) : super(key: key);

  @override
  _MemberBodyState createState() => _MemberBodyState();
}

class _MemberBodyState extends State<MemberBody> {
  @override
  Widget build(BuildContext context) {
    List<UserModel> _data = Provider.of<List<UserModel>>(context);
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
            width: double.maxFinite,
            height: 60.0,
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: _data[index].profile != null
                        ? NetworkImage(_data[index].profile)
                        : AssetImage('assets/images/user.png'),
                    radius: 25,
                  ),
                  SizedBox(width: 7.0),
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
                            _data[index].email,
                            maxLines: 2,
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: double.maxFinite,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                FlutterIcons.trash_o_faw,
                                color: Colors.red[300],
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  title: Text(
                                    'Are you sure!',
                                    style: TextStyle(
                                      fontFamily: 'Producrt Sans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.0,
                                    ),
                                  ),
                                  content: Text(
                                    'do you really want to remove member \' ${_data[index].name} \' from the community?',
                                    style: TextStyle(
                                      fontFamily: 'Product Sans',
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  actions: [
                                    InkWell(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 12.0),
                                        child: Text(
                                          'NO',
                                          style: TextStyle(
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    InkWell(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Text(
                                          'YES',
                                          style: TextStyle(
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        bool result = await deleteMember(
                                            _data[index].uid);
                                        Navigator.of(context).pop();

                                        if (result) {
                                          showFlushBar(
                                            context: context,
                                            title: 'Member Removed!',
                                            message:
                                                'Member profile deleted successfully...',
                                          );
                                        } else {
                                          showFlushBar(
                                            context: context,
                                            title: 'Operation Failed...',
                                            message:
                                                'Deletion failed, please try again!!!',
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(width: 10.0),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 3.0),
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
                                  builder: (context) =>
                                      MemberProfile(data: _data[index]),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
