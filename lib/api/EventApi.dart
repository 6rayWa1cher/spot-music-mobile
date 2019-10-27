import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hm_spot_music_client/model/Event.dart';
import 'package:hm_spot_music_client/model/Player.dart';
import 'package:hm_spot_music_client/model/PlayerContacts.dart';
import 'package:hm_spot_music_client/model/Song.dart';
import 'dart:async';

class EventApi {
  final Dio _dio;

  EventApi(this._dio);

  Future<List<Event>> getEvents() {
    var completer = Completer<List<Event>>();

    Image photo = Image.asset("assets/images/event/player-photo.png");

    Completer<Size> photoSizeCompleter = Completer();

    photo.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          photoSizeCompleter.complete(size);
        },
      ),
    );

    photoSizeCompleter.future.then((size) {
      Size photoSize = size;

      Player player = Player(
          name: "Brew Addison",
          photo: photo,
          photoSize: photoSize,
          description: "Я играющий на гитаре бомж",
          contacts: PlayerContacts(
              vk: "https://vk.com/id264240586",
              instagram: "https://www.instagram.com/mikhailov605/",
              facebook: "https://www.facebook.com/elonreevesmusk/",
              telegram: "https://t.me/rm_rf0",
              spotify: "https://open.spotify.com/show/5l7WLLoi7ji8QzyOtjERCH"));

      List<Song> songs = List();

      songs.add(Song(name: "My life", albumName: "high dreams"));
      songs.add(Song(name: "Never do that", albumName: "high dreams"));
      songs.add(Song(name: "Make me happy", albumName: "in new york"));

      List<Event> events = List();
      events.add(Event(
          id: 1,
          player: player,
          latitude: 55.7753448,
          longitude: 37.6698494,
          start: DateTime.now().subtract(Duration(hours: 1)),
          duration: Duration(hours: 10),
          songs: songs));
      completer.complete(events);
    });

    return completer.future;
  }
}
