import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/COMPONENTS/InputField.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class NewSponsor extends StatefulWidget {
  NewSponsor({Key key}) : super(key: key);

  @override
  _NewSponsorState createState() => _NewSponsorState();
}

class _NewSponsorState extends State<NewSponsor> {
  PlatformFile _image;
  TextEditingController _sponsor;
  bool isLoading;

  Future sponserAdd() async {}

  @override
  void initState() {
    _sponsor = TextEditingController();
    isLoading = false;
    super.initState();
  }

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
          'Add a sponsors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
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
        child: ListView(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles();

                    // ImagePicker _picker = ImagePicker();
                    // PickedFile _image = await _picker.getImage(
                    //   source: ImageSource.gallery,
                    // );
                    // if (_image != null) {
                    //   if (_image.path.toString().contains('.jpg') ||
                    //       _image.path.toString().contains('.JPG') ||
                    //       _image.path.toString().contains('.png') ||
                    //       _image.path.toString().contains('.PNG') ||
                    //       _image.path.toString().contains('.jpeg') ||
                    //       _image.path.toString().contains('.JPEG')) {
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
                      // this._image = _cropped;
                      _image = result.files.first;
                    });
                    // } else {
                    //   showFlushBar(
                    //     context: context,
                    //     title: 'Image with invalid format selected!!!',
                    //     message:
                    //         'Select a image with ".jpg" or ".png" format only and try again.',
                    //   );
                    // }
                    // }
                  },
                  child: _image == null
                      ? Container(
                          color: Colors.grey,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FlutterIcons.add_a_photo_mdi,
                                size: 280.0,
                                color: Colors.white54,
                              ),
                              Text(
                                'Click to add a image...',
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Image.file(
                          // this._image,
                          File(_image.path),
                          fit: BoxFit.fitWidth,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 15.0,
              ),
              child: InputField(
                label: 'Sponsor Details',
                controller: _sponsor,
                labelEnable: true,
                minLines: 5,
                maxLines: 200,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (this._image != null && this._sponsor.text != '') {
            setState(() {
              isLoading = true;
            });
            bool result = await addSponsor(this._image, this._sponsor.text);
            // bool result =

            if (result) {
              setState(() {
                isLoading = false;
              });
              Navigator.pop(context, true);
            } else {
              setState(() {
                isLoading = false;
              });
              showFlushBar(
                context: context,
                title: 'Error Occurred!!!',
                message: 'Please try again...',
              );
            }
          } else {
            showFlushBar(
              context: context,
              title: 'No field can remain empty!!!',
              message: 'Please fill all details',
            );
          }
        },
        backgroundColor: Colors.white,
        child: Icon(
          FlutterIcons.check_faw5s,
          color: kPrimaryColor,
        ),
      ),
    );
  }
}
