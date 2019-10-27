import 'Player.dart';
import 'Song.dart';

class Event {
  int id;
  double latitude;
  double longitude;
  List<Song> songs;
  DateTime start;
  Duration duration;
  Player player;

  Event({this.id, this.player, this.latitude, this.longitude,this.start, this.duration, this.songs});
/*  factory Event.fromJson(Map<String, dynamic> json, List<Song>) =>
      new Event(jwt: json["jwt"] == null ? null : json["jwt"]);*/
}