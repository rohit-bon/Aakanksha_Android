// ignore_for_file: deprecated_member_use
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/COMPONENTS/InputField.dart';

class emailVerify extends StatefulWidget {
  String email;
  emailVerify({Key key, this.email}) : super(key: key);
  @override
  _emailVerifyState createState() => _emailVerifyState();
}

class _emailVerifyState extends State<emailVerify> {
  final TextEditingController otpcontroller = TextEditingController();
  EmailOTP myauth = EmailOTP();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            controller: otpcontroller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'OTP',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      RaisedButton(
                        padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                        onPressed: () async {
                          if (await myauth.verifyOTP(otp: otpcontroller.text) ==
                              true) {
                            Navigator.popAndPushNamed(context, '/user');
                            showFlushBar(title: 'Done', message: 'verefied');
                          } else {
                            showFlushBar(title: 'wrong', message: 'Invalid');
                          }
                        },
                        child: Text('Verify',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold)),
                        color: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      RaisedButton(
                        padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                        onPressed: () async {
                          myauth.setConfig(
                              appEmail: "me@rohitbongade.com",
                              appName: "Aakanksha",
                              userEmail: widget.email,
                              otpLength: 6,
                              otpType: OTPType.digitsOnly);
                          if (await myauth.sendOTP() == true) {
                            showFlushBar(title: 'Done', message: 'Sent');
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Oops, OTP send failed"),
                            ));
                          }
                        },
                        child: Text('Request OTP',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold)),
                        color: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      )
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
