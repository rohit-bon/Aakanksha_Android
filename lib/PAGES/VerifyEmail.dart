import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:humanly/PAGES/UserScreen.dart';
import 'dart:async';

class verifyEmailPage extends StatefulWidget {
  String email;
  verifyEmailPage({Key key, this.email}) : super(key: key);

  @override
  State<verifyEmailPage> createState() => _verifyEmailPageState();
}

class _verifyEmailPageState extends State<verifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer timer;
  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser.emailVerified;
    if (isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer.cancel();

    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser.emailVerified;
    });
    if (isEmailVerified) timer.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      // Utils.showSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? Navigator.popAndPushNamed(context, '/user')
      : Scaffold(
          appBar: AppBar(
            title: Text('Verify Email'),
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'A Verification Email has been sent to your email.',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 24,
                ),
                ElevatedButton.icon(
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    icon: Icon(
                      Icons.email,
                      size: 32,
                    ),
                    label: Text(
                      'Resend Email',
                      style: TextStyle(fontSize: 24),
                    )),
                SizedBox(
                  height: 8,
                ),
                TextButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50)),
                    child: Text(
                      'Cancle',
                      style: TextStyle(fontSize: 24),
                    ))
              ],
            ),
          ),
        );
}
