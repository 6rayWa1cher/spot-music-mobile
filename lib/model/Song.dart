import 'package:flutter/widgets.dart';

class Song {
  String name;
  Image coverPhoto;
  String albumName;

  Song({this.name, this.albumName, this.coverPhoto});

/*  factory Song.fromJson(Map<String, dynamic> json) => new Song(
      name: json["name"] == null ? null : json["name"],
      coverPhotoUrl: json["coverPhotoUrl"] == null ? null : json["coverPhotoUrl"],
      albumName: json["albumName"] == null ? null : json["albumName"]
  );*/
}
