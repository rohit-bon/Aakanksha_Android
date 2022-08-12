import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String profile;
  String name;
  String username;
  String gender;
  String bgroup;
  String email;
  String contact;
  String address;
  String pincode;
  String password;
  String dob;
  double lat;
  double lng;
  String currentArea;

  UserModel({
    this.uid,
    this.profile,
    this.name,
    this.username,
    this.gender,
    this.bgroup,
    this.email,
    this.contact,
    this.address,
    this.pincode,
    this.password,
    this.dob,
    this.lat = 20.049159,
    this.lng = 64.4018361,
    this.currentArea = '000000',
  });

  Map<String, dynamic> toMap() {
    return {
      'profile': profile,
      'name': name,
      'username': username,
      'gender': gender,
      'bgroup': bgroup,
      'email': email,
      'contact': contact,
      'address': address,
      'pincode': pincode,
      'password': password,
      'dob': dob,
      'lat': lat,
      'lng': lng,
      'currentArea': currentArea,
    };
  }

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    if (doc == null) return null;

    Map<String, dynamic> map = doc.data();

    return UserModel(
      uid: doc.id,
      profile: map['profile'],
      name: map['name'],
      username: map['username'],
      gender: map['gender'],
      bgroup: map['bgroup'],
      email: map['email'],
      contact: map['contact'],
      address: map['address'],
      pincode: map['pincode'],
      password: map['password'],
      dob: map['dob'],
      lat: map['lat'],
      lng: map['lng'],
      currentArea: map['currentArea'],
    );
  }
}
