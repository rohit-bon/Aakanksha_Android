// ignore_for_file: unrelated_type_equality_checks, curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/AdminAppDrawer.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/UserModel.dart';
import 'package:humanly/PAGES/ADMIN/MemberProfile.dart';
import 'package:provider/provider.dart';

class searchMember extends StatelessWidget {
  const searchMember({Key key}) : super(key: key);

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
          'Family Members',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
          ),
        ),
      ),
      body: StreamProvider<List<UserModel>>(
        create: (_) => getMembers(),
        child: Mem(),
      ), //HomeBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Addmem()));
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

class Mem extends StatefulWidget {
  Mem({Key key}) : super(key: key);

  @override
  _MemState createState() => _MemState();
}

class _MemState extends State<Mem> {
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
                                FlutterIcons.trash_alt_faw5,
                              ),
                            ),
                            onTap: () async {
                              var id = _data[index].uid;
                              try {
                                var fam = await FirebaseFirestore.instance
                                    .collection('memberDatabase')
                                    .doc(currentUser.uid)
                                    .collection('family')
                                    .get();

                                try {
                                  if (fam != null || fam.docs.length > 0) {
                                    await FirebaseFirestore.instance
                                        .collection('memberDatabase')
                                        .doc(currentUser.uid)
                                        .collection('family')
                                        .doc(id)
                                        .delete();
                                  }

                                  // await FirebaseFirestore.instance
                                  //     .collection('memberDatabase')
                                  //     .doc(currentUser.uid)
                                  //     .delete();

                                  showFlushBar(
                                    context: context,
                                    title: 'Member Deleted Successfully.',
                                    message: 'Perfect',
                                  );
                                } catch (e) {
                                  showFlushBar(
                                    context: context,
                                    title: 'Error',
                                    message: 'Perfect',
                                  );
                                }
                              } catch (e) {
                                showFlushBar(
                                  context: context,
                                  title: 'Error',
                                  message: 'Perfect',
                                );
                              }
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

class Addmem extends StatefulWidget {
  const Addmem({Key key}) : super(key: key);

  @override
  State<Addmem> createState() => _AddmemState();
}

class _AddmemState extends State<Addmem> {
  TextEditingController _search = TextEditingController();
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
          'Search Members',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                child: Image(
                  image: AssetImage("assets/images/login.jpg"),
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                child: Form(
                  // key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            controller: _search,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Search by mobile no ',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      RaisedButton(
                        padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewMember(
                                        num: _search.text,
                                      )));
                        },
                        child: Text('Search',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold)),
                        color: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewMember extends StatefulWidget {
  NewMember({Key key, this.num}) : super(key: key);
  String num;

  @override
  State<NewMember> createState() => _NewMemberState();
}

class _NewMemberState extends State<NewMember> {
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
          'Add Members',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
          ),
        ),
      ),
      body: StreamProvider<List<UserModel>>(
        create: (_) => searchMembers(widget.num),
        child: finalresultmember(
          num: widget.num,
        ),
      ), //HomeBody(),
    );
  }
}

class finalresultmember extends StatefulWidget {
  finalresultmember({Key key, this.num}) : super(key: key);
  String num;

  @override
  State<finalresultmember> createState() => _finalresultmemberState();
}

class _finalresultmemberState extends State<finalresultmember> {
  @override
  Widget build(BuildContext context) {
    List<UserModel> _data = Provider.of<List<UserModel>>(context);
    if (_data == null) {
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
        // ignore: missing_return
        itemBuilder: (BuildContext context, int index) {
          if (_data[index].contact != num)
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
                              style: const TextStyle(
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
                              style: const TextStyle(
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
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  FlutterIcons.add_circle_mdi,
                                ),
                              ),
                              onTap: () async {
                                UserModel _value = UserModel(
                                  name: _data[index].name,
                                  username: _data[index].username,
                                  gender: _data[index].gender,
                                  bgroup: _data[index].bgroup,
                                  email: _data[index].email,
                                  contact: _data[index].contact,
                                  address: _data[index].address,
                                  pincode: _data[index].pincode,
                                  password: _data[index].password,
                                  dob: _data[index].dob,
                                );

                                DocumentReference _query =
                                    await FirebaseFirestore.instance
                                        .collection('memberDatabase')
                                        .doc(currentUser.uid)
                                        .collection('family')
                                        .add(_value.toMap());

                                showFlushBar(
                                  context: context,
                                  title: 'Member Added Successfully.',
                                  message: 'Perfect',
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
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Divider(
              thickness: 0.5,
            ),
          );
        },
      );
    }
  }
}
