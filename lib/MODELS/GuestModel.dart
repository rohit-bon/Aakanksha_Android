import 'package:cloud_firestore/cloud_firestore.dart';

class GuestModel {
  String id;
  String uid;
  String name;
  String username;
  String gender;
  String bgroup;
  String contact;
  double lat;
  double lng;
  var timestamp;
  String address;
  bool resolved;
  int sosRange;

  GuestModel({
    this.id,
    this.uid,
    this.name,
    this.username,
    this.gender,
    this.bgroup,
    this.contact,
    this.lat,
    this.lng,
    this.timestamp,
    this.address,
    this.resolved = false,
    this.sosRange,
  });

  GuestModel copyWith({
    String id,
    String uid,
    String name,
    String username,
    String gender,
    String bgroup,
    String contact,
    double lat,
    double lng,
    var timestamp,
    String address,
    bool resolved,
    int sosRange,
  }) {
    return GuestModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      bgroup: bgroup ?? this.bgroup,
      contact: contact ?? this.contact,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      timestamp: timestamp ?? this.timestamp,
      address: address ?? this.address,
      resolved: resolved ?? this.resolved,
      sosRange: sosRange ?? this.sosRange,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'gender': gender,
      'bgroup': bgroup,
      'contact': contact,
      'lat': lat,
      'lng': lng,
      'timestamp': timestamp,
      'address': address,
      'resolved': resolved,
      'sosRange': sosRange,
    };
  }

  factory GuestModel.fromMap(DocumentSnapshot doc) {
    if (doc == null) return null;

    Map<String, dynamic> map = doc.data();

    return GuestModel(
      id: doc.id,
      uid: map['uid'],
      name: map['name'],
      username: map['username'],
      gender: map['gender'],
      bgroup: map['bgroup'],
      contact: map['contact'],
      lat: map['lat'],
      lng: map['lng'],
      timestamp: map['timestamp'],
      address: map['address'],
      resolved: map['resolved'],
      sosRange: map['sosRange'],
    );
  }
}
