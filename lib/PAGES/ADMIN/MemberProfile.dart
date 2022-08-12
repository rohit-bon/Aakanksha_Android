import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/COMPONENTS/InputField.dart';
import 'package:humanly/COMPONENTS/ProfileActionButton.dart';
import 'package:humanly/MODELS/UserModel.dart';
import 'package:humanly/PAGES/ADMIN/MemberTracker.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class MemberProfile extends StatelessWidget {
  final UserModel data;

  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _dob = TextEditingController();
  TextEditingController _pincode = TextEditingController();

  MemberProfile({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _email.text = data.email;
    _phone.text = data.contact;
    _address.text = data.address;
    _dob.text = data.dob;
    _pincode.text = data.pincode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: IconTheme.of(context).copyWith(
          color: Colors.white,
        ),
        title: Text(
          'Member Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: CircleAvatar(
                          radius: 90.0,
                          backgroundImage: data.profile != null
                              ? NetworkImage(data.profile)
                              : AssetImage('assets/images/user.png'),
                        ),
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(10.0),
                      alignment: Alignment.center,
                      child: Text(
                        data.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 50.0,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ProfileActionButton(
                          title: 'Call',
                          icon: FlutterIcons.phone_call_fea,
                          onTap: () async {
                            if (await canLaunch('tel:' + data.contact)) {
                              await launch('tel:' + data.contact);
                            } else {
                              showFlushBar(
                                context: context,
                                title: 'Unable to launch dialer!',
                                message:
                                    'No supported app found on device, please install one & try again.',
                              );
                            }
                          },
                        ),
                        ProfileActionButton(
                          title: 'Track',
                          icon: FlutterIcons.location_arrow_faw5s,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MemberTracker(
                                  user: data,
                                ),
                              ),
                            );
                          },
                        ),
                        ProfileActionButton(
                          title: 'Mail',
                          icon: FlutterIcons.at_faw5s,
                          onTap: () async {
                            if (await canLaunch(
                                'mailto:${data.email}?subject=SUBJECT&body=SUBJECT')) {
                              await launch(
                                  'mailto:${data.email}?subject=SUBJECT&body=SUBJECT');
                            } else {
                              showFlushBar(
                                context: context,
                                title: 'Unable to launch mail app!',
                                message:
                                    'No supported app found on device, please install one & try again.',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    InputField(
                      label: 'E-mail',
                      enable: false,
                      labelEnable: true,
                      controller: this._email,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    InputField(
                      label: 'Contact',
                      controller: this._phone,
                      labelEnable: true,
                      enable: false,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    InputField(
                      label: 'Address',
                      labelEnable: true,
                      enable: false,
                      controller: this._address,
                      maxLines: 10,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InputField(
                            label: 'Date of Birth',
                            labelEnable: true,
                            controller: this._dob,
                            enable: false,
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: InputField(
                            label: 'Pincode',
                            labelEnable: true,
                            enable: false,
                            controller: this._pincode,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
