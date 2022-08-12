import 'package:cloud_firestore/cloud_firestore.dart';

class HelpReviewModel {
  String docID;
  String helpID;
  String helperName;
  String helpLocation;
  double lat;
  double lng;
  var timeStamp;
  int ratedAs;

  HelpReviewModel({
    this.docID,
    this.helpID,
    this.helperName,
    this.helpLocation,
    this.lat,
    this.lng,
    this.timeStamp,
    this.ratedAs,
  });

  Map<String, dynamic> toMap() {
    return {
      'helpID': helpID,
      'helperName': helperName,
      'helpLocation': helpLocation,
      'lat': lat,
      'lng': lng,
      'timeStamp': timeStamp,
      'ratedAs': ratedAs,
    };
  }

  factory HelpReviewModel.fromMap(DocumentSnapshot doc) {
    if (doc == null) return null;

    Map<String, dynamic> map = doc.data();

    return HelpReviewModel(
      docID: doc.id,
      helpID: map['helpID'],
      helperName: map['helperName'],
      helpLocation: map['helpLocation'],
      lat: map['lat'],
      lng: map['lng'],
      timeStamp: map['timeStamp'],
      ratedAs: map['ratedAs'],
    );
  }
}
