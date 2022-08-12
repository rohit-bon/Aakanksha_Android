import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/MODELS/HelpReviewModel.dart';
import 'package:humanly/MODELS/HelperModel.dart';
import 'package:humanly/MODELS/GuestModel.dart';
import 'package:humanly/MODELS/SponsorModel.dart';
import 'package:humanly/MODELS/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Reference _profileRef =
    FirebaseStorage.instance.ref().child('profileImages/');

final Reference _sponsorRef =
    FirebaseStorage.instance.ref().child('sponsorImages/');

Future<void> storeCache(String uid) async {
  final SharedPreferences _cache = await SharedPreferences.getInstance();
  _cache.setBool('isLoggedIn', true);
  _cache.setString('uid', uid);
}

Stream<List<UserModel>> getMembersData() {
  var _responce = FirebaseFirestore.instance
      .collection('memberDatabase')
      .orderBy('name')
      .snapshots()
      .map((event) => event.docs.map((doc) => UserModel.fromDoc(doc)).toList());

  return _responce;
}

Stream<int> getResolvedCount() {
  var _responce = FirebaseFirestore.instance
      .collection('sosAlert')
      .where('resolved', isEqualTo: true)
      .snapshots()
      .map((event) => event.docs.length);

  return _responce;
}

Future<String> uploadProfileImage(String uID, PlatformFile image) async {
  String imageExtension;

  if (image.toString().contains('.png')) {
    imageExtension = '.png';
  } else if (image.toString().contains('.PNG')) {
    imageExtension = '.PNG';
  } else if (image.toString().contains('.jpg')) {
    imageExtension = '.jpg';
  } else if (image.toString().contains('.JPG')) {
    imageExtension = '.JPG';
  } else if (image.toString().contains('.jpeg')) {
    imageExtension = '.jpeg';
  } else if (image.toString().contains('.JPEG')) {
    imageExtension = '.JPEG';
  }

  try {
    final file = File(image.path);
    await _profileRef.child(uID + imageExtension).putFile(file);
    String imageURL =
        await _profileRef.child(uID + imageExtension).getDownloadURL();
    return imageURL.toString();
  } catch (e) {
    print(e.toString());
    return '';
  }
}

Future<String> updateProfileImage(PlatformFile image) async {
  if (currentUser.profile != null) {
    try {
      await _profileRef.child(currentUser.uid + '.png').delete();
    } catch (e) {
      print(e);
      try {
        await _profileRef.child(currentUser.uid + '.PNG').delete();
      } catch (e) {
        print(e);
        try {
          await _profileRef.child(currentUser.uid + '.jpg').delete();
        } catch (e) {
          print(e);
          try {
            await _profileRef.child(currentUser.uid + '.JPG').delete();
          } catch (e) {
            print(e);
            try {
              await _profileRef.child(currentUser.uid + '.JPEG').delete();
            } catch (e) {
              print(e);
              try {
                await _profileRef.child(currentUser.uid + '.jpeg').delete();
              } catch (e) {
                print(e);
              }
            }
          }
        }
      }
    }
  }

  String imageExtension;

  if (image.toString().contains('.png')) {
    imageExtension = '.png';
  } else if (image.toString().contains('.PNG')) {
    imageExtension = '.PNG';
  } else if (image.toString().contains('.jpg')) {
    imageExtension = '.jpg';
  } else if (image.toString().contains('.JPG')) {
    imageExtension = '.JPG';
  } else if (image.toString().contains('.jpeg')) {
    imageExtension = '.jpeg';
  } else if (image.toString().contains('.JPEG')) {
    imageExtension = '.JPEG';
  }

  try {
    final file = File(image.path);
    await _profileRef.child(currentUser.uid + imageExtension).putFile(file);

    String imageURL = await _profileRef
        .child(currentUser.uid + imageExtension)
        .getDownloadURL();

    await FirebaseFirestore.instance
        .collection('memberDatabase')
        .doc(currentUser.uid)
        .update({
      'profile': imageURL.toString(),
    });

    return imageURL.toString();
  } catch (e) {
    print(e.toString());
    return '';
  }
}

Future<GuestModel> sendSosAlert(GuestModel _data) async {
  DocumentReference _query = await FirebaseFirestore.instance
      .collection('sosAlert')
      .add(_data.toMap());

  DocumentSnapshot _snap = await FirebaseFirestore.instance
      .collection('sosAlert')
      .doc(_query.id)
      .get();

  return GuestModel.fromMap(_snap);
}

Stream<GuestModel> getSosAlerts() {
  var _returnable;
  try {
    _returnable = FirebaseFirestore.instance
        .collection('sosAlert')
        .orderBy('timestamp', descending: true)
        .where('resolved', isEqualTo: false)
        .snapshots()
        .map(
          (event) => GuestModel.fromMap(event.docs.first),
        );
  } catch (e) {
    print('db_error: ' + e.toString());
  }

  return _returnable;
}

Stream<GuestModel> getSosTrack(String id) {
  var _returnable = FirebaseFirestore.instance
      .collection('sosAlert')
      .doc(id)
      .snapshots()
      .map((event) => GuestModel.fromMap(event));

  return _returnable;
}

Stream<List<HelpReviewModel>> myReviews() {
  var _data = FirebaseFirestore.instance
      .collection('memberDatabase')
      .doc(currentUser.uid)
      .collection('ratings')
      .orderBy('timeStamp')
      .snapshots()
      .map((event) =>
          event.docs.map((doc) => HelpReviewModel.fromMap(doc)).toList());
  return _data;
}

Stream<List<HelperModel>> getHelpers() {
  var _returnable = FirebaseFirestore.instance
      .collection('sosAlert')
      .doc(sosRequest.id)
      .collection('helpers')
      .snapshots()
      .map(
        (event) => event.docs.map((e) => HelperModel.fromDoc(e)).toList(),
      );

  return _returnable;
}

Future<bool> updateNoRatings(List<HelperModel> data) async {
  try {
    for (HelperModel e in data) {
      await FirebaseFirestore.instance
          .collection('sosAlert')
          .doc(sosRequest.id)
          .collection('helpers')
          .doc(e.id)
          .update({'rating': 0});
    }
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<bool> updateRatings(Map<String, int> data) async {
  try {
    for (MapEntry e in data.entries) {
      String key = e.key;
      int value = (e.value != 0) ? e.value : 1;

      await FirebaseFirestore.instance
          .collection('sosAlert')
          .doc(sosRequest.id)
          .collection('helpers')
          .doc(key)
          .update({'rating': value});

      await FirebaseFirestore.instance
          .collection('memberDatabase')
          .doc(key)
          .collection('ratings')
          .add({
        'helpID': sosRequest.id,
        'helperName': sosRequest.name,
        'username': sosRequest.username,
        'helpLocation': sosRequest.address,
        'lat': sosRequest.lat,
        'lng': sosRequest.lng,
        'ratedAs': value,
        'timeStamp': sosRequest.timestamp,
      });
    }
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<bool> deleteMember(String uid) async {
  try {
    var ratings = await FirebaseFirestore.instance
        .collection('memberDatabase')
        .doc(uid)
        .collection('ratings')
        .get();

    try {
      if (ratings != null || ratings.docs.length > 0) {
        for (QueryDocumentSnapshot q in ratings.docs) {
          await FirebaseFirestore.instance
              .collection('memberDatabase')
              .doc(uid)
              .collection('ratings')
              .doc(q.id)
              .delete();
        }
      }

      await FirebaseFirestore.instance
          .collection('memberDatabase')
          .doc(uid)
          .delete();

      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<bool> addSponsor(PlatformFile image, String details) async {
  String imageExtension;

  if (image.toString().contains('.png')) {
    imageExtension = '.png';
  } else if (image.toString().contains('.PNG')) {
    imageExtension = '.PNG';
  } else if (image.toString().contains('.jpg')) {
    imageExtension = '.jpg';
  } else if (image.toString().contains('.JPG')) {
    imageExtension = '.JPG';
  } else if (image.toString().contains('.jpeg')) {
    imageExtension = '.jpeg';
  } else if (image.toString().contains('.JPEG')) {
    imageExtension = '.JPEG';
  }

  SponsorModel _data = SponsorModel(
    sponsorDetail: details,
    published: DateTime.now(),
  );

  try {
    var doc = await FirebaseFirestore.instance
        .collection('SponsorData')
        .add(_data.toMap());

    String fileName = doc.id + imageExtension;

    final file = File(image.path);

    await _sponsorRef.child(fileName).putFile(file);

    String imageURL = await _sponsorRef.child(fileName).getDownloadURL();

    await FirebaseFirestore.instance
        .collection('SponsorData')
        .doc(doc.id)
        .update({'imageURL': imageURL});

    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<bool> deleteSponsor(String id) async {
  if (id != null) {
    try {
      await _sponsorRef.child(id + '.png').delete();
    } catch (e) {
      print(e);
      try {
        await _sponsorRef.child(id + '.PNG').delete();
      } catch (e) {
        print(e);
        try {
          await _sponsorRef.child(id + '.jpg').delete();
        } catch (e) {
          print(e);
          try {
            await _sponsorRef.child(id + '.JPG').delete();
          } catch (e) {
            print(e);
            try {
              await _sponsorRef.child(id + '.JPEG').delete();
            } catch (e) {
              print(e);
              try {
                await _sponsorRef.child(id + '.jpeg').delete();
              } catch (e) {
                print(e);
                return false;
              }
            }
          }
        }
      }
    }
  }
  try {
    await FirebaseFirestore.instance.collection('SponsorData').doc(id).delete();
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<List<Map<String, dynamic>>> getLeaderboard() async {
  List<Map<String, dynamic>> _return = [];

  var _users = await FirebaseFirestore.instance
      .collection('memberDatabase')
      .orderBy('name')
      .get();

  for (QueryDocumentSnapshot element in _users.docs) {
    UserModel _temp = UserModel.fromDoc(element);

    var _data = await FirebaseFirestore.instance
        .collection('memberDatabase')
        .doc(_temp.uid)
        .collection('ratings')
        .get();

    List<HelpReviewModel> _rate =
        _data.docs.map((e) => HelpReviewModel.fromMap(e)).toList();
    int rating = 0;

    for (HelpReviewModel i in _rate) {
      rating += i.ratedAs;
    }

    _return.add(
      {
        'uid': _temp.uid,
        'profile': _temp.profile,
        'name': _temp.name,
        'contact': _temp.contact,
        'rating': rating,
        'totalRating': (_rate.length),
      },
    );
  }

  return _return;
}

Stream<List<UserModel>> getMembers() {
  var _responce = FirebaseFirestore.instance
      .collection('memberDatabase')
      .doc(currentUser.uid)
      .collection('family')
      .orderBy('name')
      .snapshots()
      .map((event) => event.docs.map((doc) => UserModel.fromDoc(doc)).toList());

  return _responce;
}

Stream<List<SponsorModel>> getSponsors() {
  var _returnable =
      FirebaseFirestore.instance.collection('SponsorData').snapshots().map(
            (event) => event.docs
                .map(
                  (e) => SponsorModel.fromMap(e),
                )
                .toList(),
          );

  return _returnable;
}

Stream<List<UserModel>> searchMembers(String num) {
  var _responce = FirebaseFirestore.instance
      .collection('memberDatabase')
      .where('contact', isEqualTo: num)
      .orderBy('name')
      .snapshots()
      .map((event) => event.docs.map((doc) => UserModel.fromDoc(doc)).toList());

  return _responce;
}

Future<Map<String, int>> getDataCounts() async {
  Map<String, int> _return = {};

  var mData =
      await FirebaseFirestore.instance.collection('memberDatabase').get();
  int members = mData.docs.length;
  var sData = await FirebaseFirestore.instance.collection('SponsorData').get();
  int sponsers = sData.docs.length;
  var aData = await FirebaseFirestore.instance.collection('sosAlert').get();
  int sosAlerts = aData.docs.length;

  _return = {
    'members': members,
    'sponsers': sponsers,
    'sosAlerts': sosAlerts,
  };

  return _return;
}

Stream<List<GuestModel>> getSosAlert() {
  var _returnable = FirebaseFirestore.instance
      .collection('sosAlert')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (event) => event.docs
            .map(
              (e) => GuestModel.fromMap(e),
            )
            .toList(),
      );

  return _returnable;
}

Stream<UserModel> getMember(String uid) {
  var _return = FirebaseFirestore.instance
      .collection('memberDatabase')
      .doc(uid)
      .snapshots()
      .map((event) => UserModel.fromDoc(event));

  return _return;
}

Future<List<HelperModel>> getHelpersList(String uid) async {
  var _data = await FirebaseFirestore.instance
      .collection('sosAlert')
      .doc(uid)
      .collection('helpers')
      .get();

  List<HelperModel> _return =
      _data.docs.map((e) => HelperModel.fromDoc(e)).toList();

  return _return;
}

Future<bool> updateSosStatus(String uid, bool status) async {
  try {
    await FirebaseFirestore.instance.collection('sosAlert').doc(uid).update({
      'resolved': status,
    });
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}
