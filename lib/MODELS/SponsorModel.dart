import 'package:cloud_firestore/cloud_firestore.dart';

class SponsorModel {
  String id;
  String sponsorDetail;
  String imageURL;
  var published;

  SponsorModel({
    this.id,
    this.sponsorDetail,
    this.imageURL,
    this.published,
  });

  SponsorModel copyWith({
    String id,
    String sponsorDetail,
    String imageURL,
    var published,
  }) {
    return SponsorModel(
      id: id ?? this.id,
      sponsorDetail: sponsorDetail ?? this.sponsorDetail,
      imageURL: imageURL ?? this.imageURL,
      published: published ?? this.published,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryTitle': sponsorDetail,
      'imageURL': imageURL,
      'published': published,
    };
  }

  factory SponsorModel.fromMap(DocumentSnapshot doc) {
    if (doc == null) return null;

    Map<String, dynamic> map = doc.data();

    return SponsorModel(
      id: doc.id,
      sponsorDetail: map['categoryTitle'],
      imageURL: map['imageURL'],
      published: map['published'],
    );
  }
}
