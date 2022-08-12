import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/COMPONENTS/InputField.dart';
import 'package:humanly/COMPONENTS/OptionButton.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:file_picker/file_picker.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _name;
  TextEditingController _username;
  TextEditingController _gender;
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
  FocusNode _genderFocus;
  FocusNode _bgroupFocus;
  FocusNode _emailFocus;
  FocusNode _phoneFocus;
  FocusNode _addressFocus;
  FocusNode _pincodeFocus;
  FocusNode _passFocus;
  FocusNode _passConfirmFocus;

  File _profileImage;

  bool isLoading;
  bool isEditing;

  @override
  void initState() {
    _name = TextEditingController();
    _username = TextEditingController();
    _gender = TextEditingController();
    _bgroup = TextEditingController();
    _email = TextEditingController();
    _phone = TextEditingController();
    _address = TextEditingController();
    _dob = TextEditingController();
    _pincode = TextEditingController();
    _pass = TextEditingController();
    _passConfirm = TextEditingController();

    _name.text = currentUser.name;
    _username.text = currentUser.username;
    _gender.text = currentUser.gender;
    _bgroup.text = currentUser.bgroup;
    _email.text = currentUser.email;
    _phone.text = currentUser.contact;
    _address.text = currentUser.address;
    _pincode.text = currentUser.pincode;
    _dob.text = currentUser.dob;
    _pass.text = currentUser.password;
    _passConfirm.text = currentUser.password;

    _nameFocus = FocusNode();
    _usernameFocus = FocusNode();
    _genderFocus = FocusNode();
    _bgroupFocus = FocusNode();
    _emailFocus = FocusNode();
    _phoneFocus = FocusNode();
    _addressFocus = FocusNode();
    _pincodeFocus = FocusNode();
    _passFocus = FocusNode();
    _passConfirmFocus = FocusNode();

    isLoading = false;
    isEditing = false;
    super.initState();
  }

  void fieldUnfocus() {
    _nameFocus.unfocus();
    _usernameFocus.unfocus();
    _genderFocus.unfocus();
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
        Navigator.of(context).pop();
        if (_image != null) {
          setState(() {
            isLoading = true;
          });
          String _responce = await updateProfileImage(_image);
          if (_responce != '') {
            setState(() {
              currentUser.profile = _responce;
              isLoading = false;
            });
            showFlushBar(
              context: context,
              title: 'Profile Image Updated Successfully.',
              message: 'Perfect',
            );
          } else {
            setState(() {
              isLoading = false;
            });
            showFlushBar(
              context: context,
              title: 'Image upload failed!!!',
              message: 'Please retry after sometime',
            );
          }
        }
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

  Future<void> updateProfile(BuildContext context) async {
    fieldUnfocus();
    if (_name.text != '' &&
        _username.text != '' &&
        _gender.text != '' &&
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

            currentUser.name = _name.text;
            currentUser.username = _username.text;
            currentUser.gender = _gender.text;
            currentUser.email = _email.text;
            currentUser.contact = _phone.text;
            currentUser.address = _address.text;
            currentUser.pincode = _pincode.text;
            currentUser.password = _pass.text;
            currentUser.dob = _dob.text;

            await FirebaseFirestore.instance
                .collection('memberDatabase')
                .doc(currentUser.uid)
                .update(currentUser.toMap());

            showFlushBar(
              context: context,
              title: 'Member Profile Updated Successfully.',
              message: 'Perfect',
            );

            Future.delayed(Duration(seconds: 3), () {
              setState(() {
                isLoading = false;
              });
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconTheme.of(context).copyWith(
            color: Colors.white,
          ),
          title: Text(
            'Your Profile',
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
                        Visibility(
                          visible: !isEditing,
                          child: Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 90.0,
                                    backgroundImage: currentUser.profile != null
                                        ? NetworkImage(currentUser.profile)
                                        : AssetImage('assets/images/user.png'),
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
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Name...',
                          enable: this.isEditing,
                          controller: this._name,
                          focusNode: this._nameFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'UserName...',
                          enable: this.isEditing,
                          controller: this._username,
                          focusNode: this._usernameFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Gender...',
                          enable: this.isEditing,
                          controller: this._gender,
                          focusNode: this._genderFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Blood Group...',
                          enable: this.isEditing,
                          controller: this._bgroup,
                          focusNode: this._bgroupFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Email...',
                          enable: this.isEditing,
                          controller: this._email,
                          focusNode: this._emailFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Contact...',
                          controller: this._phone,
                          enable: this.isEditing,
                          keyboardType: TextInputType.number,
                          focusNode: this._phoneFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Address...',
                          enable: this.isEditing,
                          controller: this._address,
                          maxLines: 10,
                          focusNode: this._addressFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (isEditing) {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime(2100),
                                    ).then((date) {
                                      _dob.text =
                                          DateFormat('dd-MM-yyyy').format(date);
                                    });
                                  }
                                },
                                child: InputField(
                                  label: 'Date of Birth...',
                                  labelEnable: true,
                                  controller: this._dob,
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
                                enable: this.isEditing,
                                controller: this._pincode,
                                keyboardType: TextInputType.number,
                                focusNode: this._pincodeFocus,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        InputField(
                          label: 'Password...',
                          enable: this.isEditing,
                          controller: this._pass,
                          obscureText: true,
                          focusNode: this._passFocus,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Visibility(
                          visible: this.isEditing,
                          child: InputField(
                            label: 'Confirm Password...',
                            enable: this.isEditing,
                            controller: this._passConfirm,
                            obscureText: true,
                            focusNode: this._passConfirmFocus,
                          ),
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            if (isEditing) {
                              if (_name.text != currentUser.name ||
                                  _username.text != currentUser.username ||
                                  _email.text != currentUser.email ||
                                  _phone.text != currentUser.contact ||
                                  _address.text != currentUser.address ||
                                  _pincode.text != currentUser.pincode ||
                                  _pass.text != currentUser.password ||
                                  _dob.text != currentUser.dob) {
                                updateProfile(context);
                              } else {
                                setState(() {
                                  this.isEditing = !this.isEditing;
                                });
                              }
                            } else {
                              setState(() {
                                this.isEditing = !this.isEditing;
                              });
                            }

                            // registerUser(context);
                          },
                          fillColor: kPrimaryColor,
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 15.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  this.isEditing
                                      ? 'Save Profile'
                                      : 'Edit Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Icon(
                                  this.isEditing
                                      ? FlutterIcons.user_faw5s
                                      : FlutterIcons.edit_faw5s,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _usernameFocus.dispose();
    _genderFocus.dispose();
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
