import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/COMPONENTS/InputField.dart';
import 'package:humanly/COMPONENTS/OptionButton.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:humanly/MODELS/UserModel.dart';
import 'package:humanly/PAGES/VerifyEmail.dart';
import 'package:humanly/PAGES/email.dart';
// import 'package:humanly/PAGES/email.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignUp extends StatefulWidget {
  SignUp({Key key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String _gender;
  TextEditingController _name;
  TextEditingController _username;
  // TextEditingController _gender;
  TextEditingController _bgroup;
  TextEditingController _email;
  TextEditingController _phone;
  TextEditingController _address;
  TextEditingController _dob;
  TextEditingController _pincode;
  TextEditingController _pass;
  TextEditingController _passConfirm;

  FocusNode _nameFocus;
  FocusNode _usernameFocus;
  // FocusNode _genderFocus;
  FocusNode _bgroupFocus;
  FocusNode _emailFocus;
  FocusNode _phoneFocus;
  FocusNode _addressFocus;
  FocusNode _pincodeFocus;
  FocusNode _passFocus;
  FocusNode _passConfirmFocus;

  PlatformFile _profileImage;

  bool isLoading;

  @override
  void initState() {
    _name = TextEditingController();
    _username = TextEditingController();
    // _gender = TextEditingController();
    _bgroup = TextEditingController();
    _email = TextEditingController();
    _phone = TextEditingController();
    _address = TextEditingController();
    _dob = TextEditingController();
    _pincode = TextEditingController();
    _pass = TextEditingController();
    _passConfirm = TextEditingController();

    _dob.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    _nameFocus = FocusNode();
    _usernameFocus = FocusNode();
    // _genderFocus = FocusNode();
    _bgroupFocus = FocusNode();
    _emailFocus = FocusNode();
    _phoneFocus = FocusNode();
    _addressFocus = FocusNode();
    _pincodeFocus = FocusNode();
    _passFocus = FocusNode();
    _passConfirmFocus = FocusNode();

    isLoading = false;
    super.initState();
  }

  void fieldUnfocus() {
    _nameFocus.unfocus();
    _usernameFocus.unfocus();
    // _genderFocus.unfocus();
    _bgroupFocus.unfocus();
    _emailFocus.unfocus();
    _phoneFocus.unfocus();
    _addressFocus.unfocus();
    _pincodeFocus.unfocus();
    _passFocus.unfocus();
    _passConfirmFocus.unfocus();
  }

  Future<void> setImage(BuildContext context, PlatformFile _image) async {
    if (_image.path.toString().contains('.jpg') ||
        _image.path.toString().contains('.JPG') ||
        _image.path.toString().contains('.png') ||
        _image.path.toString().contains('.PNG') ||
        _image.path.toString().contains('.jpeg') ||
        _image.path.toString().contains('.JPEG')) {
      if (_image != null) {
        // File _cropped = await ImageCropper().cropImage(
        //   sourcePath: _image.path,
        //   aspectRatio: CropAspectRatio(
        //     ratioX: 1,
        //     ratioY: 1,
        //   ),
        //   androidUiSettings: AndroidUiSettings(
        //     toolbarTitle: 'Crop Image',
        //     toolbarColor: kPrimaryColor,
        //     toolbarWidgetColor: Colors.white,
        //   ),
        // );
        setState(() {
          this._profileImage = _image;
        });
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
      showFlushBar(
        context: context,
        title: 'Image with invalid format selected!!!',
        message:
            'Select a image with ".jpg" or ".png" format only and try again.',
      );
    }
  }

  Future<void> registerUser(BuildContext context) async {
    fieldUnfocus();
    if (_name.text != '' &&
        _username.text != '' &&
        _gender != '' &&
        _bgroup.text != '' &&
        _email.text != '' &&
        _phone.text != '' &&
        _address.text != '' &&
        _pincode.text != '' &&
        _pass.text != '' &&
        _passConfirm.text != '') {
      if (_phone.text.length == 10) {
        if (_pass.text.length >= 8) {
          if (_pass.text == _passConfirm.text) {
            setState(() {
              isLoading = true;
            });

            UserModel _data = UserModel(
              name: _name.text,
              username: _username.text,
              gender: _gender,
              bgroup: _bgroup.text,
              email: _email.text,
              contact: _phone.text,
              address: _address.text,
              pincode: _pincode.text,
              password: _pass.text,
              dob: _dob.text,
            );

            DocumentReference _query = await FirebaseFirestore.instance
                .collection('memberDatabase')
                .add(_data.toMap());

            if (_profileImage != null) {
              String uri = await uploadProfileImage(
                _query.id,
                _profileImage,
              );

              if (uri == '') {
                showFlushBar(
                  context: context,
                  title: 'Problem occured while uploading profile image!!!',
                  message: 'Please wait for some time or try again.',
                );
              } else {
                setState(() {
                  isLoading = false;
                });
                _data.profile = uri;
                await FirebaseFirestore.instance
                    .collection('memberDatabase')
                    .doc(_query.id)
                    .update(_data.toMap());
                showFlushBar(
                  context: context,
                  title: 'Member Profile Created Successfully.',
                  message: 'Perfect',
                );
              }
            } else {
              showFlushBar(
                context: context,
                title: 'Member Profile Created Successfully.',
                message: 'Perfect',
              );
            }

            await storeCache(_query.id);
            Future.delayed(Duration(seconds: 5), () {
              setState(() {
                isLoading = false;
              });
              _data.uid = _query.id;
              currentUser = _data;
              Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => verifyEmailPage(
              //               email: _data.email,
              //             )));
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => emailVerify(
                            email: _data.email,
                          )));
              // Navigator.pop(context, true);
            });
          } else {
            showFlushBar(
              context: context,
              title: 'Password mismatched!!!',
              message: 'Check your password',
            );
          }
        } else {
          showFlushBar(
            context: context,
            title: 'Password too short!!!',
            message: 'Password should be minimum 8 digit in length',
          );
        }
      } else {
        showFlushBar(
          context: context,
          title: 'Invalid data found!!!',
          message: 'Check your entered data',
        );
      }
    } else {
      showFlushBar(
        context: context,
        title: 'Incomplete data found!!!',
        message: 'No field can remain empty',
      );
    }
  }

  void changeProfileImage() {
    fieldUnfocus();
    ImagePicker _picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Wrap(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: this._profileImage != null,
                    child: OptionButton(
                      buttonTitle: 'Remove Image',
                      icon: FlutterIcons.close_faw,
                      onPressed: () {
                        setState(() {
                          this._profileImage = null;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Visibility(
                    visible: this._profileImage != null,
                    child: SizedBox(width: 25.0),
                  ),
                  OptionButton(
                    buttonTitle: 'Gallery',
                    icon: FlutterIcons.photo_library_mdi,
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      PlatformFile _image = result.files.first;
                      setImage(context, _image);
                    },
                  ),
                  SizedBox(width: 25.0),
                  OptionButton(
                    buttonTitle: 'Camera',
                    icon: FlutterIcons.camera_faw5s,
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      PlatformFile _image = result.files.first;
                      setImage(context, _image);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Future signUp() async {
  //   final isValid =
  // }
  String _verticalGroupValue = "male";

  List<String> _status = ["male", "female"];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/register.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconTheme.of(context).copyWith(
            color: Colors.white,
          ),
          title: Text(
            'Register Yourself...',
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'ProductSans',
            ),
          ),
        ),
        body: ModalProgressHUD(
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
          child: SafeArea(
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
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 90.0,
                                  backgroundImage: this._profileImage == null
                                      ? AssetImage('assets/images/user.png')
                                      : FileImage(File(_profileImage.path)),
                                ),
                                Container(
                                  child: FloatingActionButton(
                                    onPressed: this.changeProfileImage,
                                    backgroundColor: kPrimaryColor,
                                    child: Icon(
                                      FlutterIcons.edit_faw5s,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Name...',
                          controller: _name,
                          focusNode: _nameFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'UserName...',
                          controller: _username,
                          focusNode: _usernameFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gender : ',
                              style:
                                  TextStyle(fontSize: 15, color: kPrimaryColor),
                            ),
                            RadioGroup<String>.builder(
                              direction: Axis.horizontal,
                              groupValue: _verticalGroupValue,
                              horizontalAlignment:
                                  MainAxisAlignment.spaceAround,
                              onChanged: (value) => setState(() {
                                _verticalGroupValue = value;
                                _gender = _verticalGroupValue;
                              }),
                              items: _status,
                              textStyle:
                                  TextStyle(fontSize: 15, color: kPrimaryColor),
                              itemBuilder: (item) => RadioButtonBuilder(
                                item,
                              ),
                            ),
                          ],
                        ),
                        // InputField(
                        //   label: 'Gender...',
                        //   controller: _gender,
                        //   focusNode: _genderFocus,
                        // ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Blood Group...',
                          controller: _bgroup,
                          focusNode: _bgroupFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Email...',
                          controller: _email,
                          focusNode: _emailFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Contact...',
                          controller: _phone,
                          keyboardType: TextInputType.number,
                          focusNode: _phoneFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Address...',
                          controller: _address,
                          maxLines: 10,
                          focusNode: _addressFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime(2100),
                                  ).then((date) {
                                    _dob.text =
                                        DateFormat('dd-MM-yyyy').format(date);
                                  });
                                },
                                child: InputField(
                                  label: 'Date of Birth...',
                                  labelEnable: true,
                                  controller: _dob,
                                  enable: false,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: InputField(
                                label: 'Pincode...',
                                controller: _pincode,
                                keyboardType: TextInputType.number,
                                focusNode: _pincodeFocus,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Password...',
                          controller: _pass,
                          obscureText: true,
                          focusNode: _passFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Confirm Password...',
                          controller: _passConfirm,
                          obscureText: true,
                          focusNode: _passConfirmFocus,
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Register',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700),
                            ),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: kPrimaryColor,
                              child: IconButton(
                                  color: Colors.white,
                                  onPressed: () {
                                    // signUp();
                                    registerUser(context);
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward,
                                  )),
                            )
                          ],
                        ),
                        // RawMaterialButton(
                        //   onPressed: () {
                        //     registerUser(context);
                        //   },
                        //   fillColor: kPrimaryColor,
                        //   elevation: 8.0,
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(80.0),
                        //   ),
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 24.0,
                        //       vertical: 15.0,
                        //     ),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Text(
                        //           'REGISTER',
                        //           style: TextStyle(
                        //             fontWeight: FontWeight.bold,
                        //             color: Colors.white,
                        //             fontSize: 24,
                        //           ),
                        //         ),
                        //         SizedBox(width: 8.0),
                        //         Icon(
                        //           FlutterIcons.users_faw5s,
                        //           color: Colors.white,
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _usernameFocus.dispose();
    // _genderFocus.dispose();
    _bgroupFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _pincodeFocus.dispose();
    _passFocus.dispose();
    _passConfirmFocus.dispose();
    super.dispose();
  }
}
