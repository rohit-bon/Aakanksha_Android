import 'package:cloud_firestore/cloud_firestore.dart';

class HelperModel {
  String id;
  String name;
  String username;
  String contact;
  String location;
  double lat;
  double lng;
  int rating;

  HelperModel({
    this.id,
    this.name,
    this.username,
    this.contact,
    this.location,
    this.lat,
    this.lng,
    this.rating = 0,
  });

  HelperModel copyWith({
    String id,
    String name,
    String username,
    String contact,
    String location,
    double lat,
    double lng,
    int rating,
  }) {
    return HelperModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      contact: contact ?? this.contact,
      location: location ?? this.location,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'contact': contact,
      'location': location,
      'lat': lat,
      'lng': lng,
      'rating': rating,
    };
  }

  factory HelperModel.fromDoc(DocumentSnapshot doc) {
    if (doc == null) return null;

    Map<String, dynamic> map = doc.data();

    return HelperModel(
      id: doc.id,
      name: map['name'],
      username: map['username'],
      contact: map['contact'],
      location: map['location'],
      lat: map['lat'],
      lng: map['lng'],
      rating: map['rating'] != null ? map['rating'] : 0,
    );
  }
}
