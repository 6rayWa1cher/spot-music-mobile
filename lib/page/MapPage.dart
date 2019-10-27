import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hm_spot_music_client/api/EventApi.dart';
import 'package:hm_spot_music_client/model/Event.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:stopper/stopper.dart';

import 'package:hm_spot_music_client/model/PlayerContacts.dart';
//import '../colors.dart';

class MapPage extends StatefulWidget {
  EventApi _eventApi;

  MapPage(EventApi eventApi) {
    this._eventApi = eventApi;
  }

  @override
  MapPageState createState() {
    return MapPageState(_eventApi);
  }
}

class MapPageState extends State<MapPage> {
  EventApi _eventApi;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Event> events = List();
  Set<Marker> markers = Set<Marker>();
  Event selectedEvent = null;
  BuildContext scaffoldContext;

  MapPageState(EventApi eventApi) {
    this._eventApi = eventApi;
  }

  SvgPicture plusSvg = SvgPicture.asset('assets/images/map/plus.svg');
  SvgPicture minusSvg = SvgPicture.asset('assets/images/map/minus.svg');
  SvgPicture findMeSvg = SvgPicture.asset('assets/images/map/find-me.svg');

  CameraPosition defaultPosition =
      CameraPosition(target: LatLng(55.754529, 37.620784), zoom: 13);
  GoogleMapController controller;

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  Widget _bottomSheetBuilder(BuildContext context) {
    Image photo = selectedEvent.player.photo;
    Size photoSize = selectedEvent.player.photoSize;
    var phoneHeight = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width - 16;

    List<Container> contactLinks = List();
    bool isFirstContact = true;

    PlayerContacts playerContacts = selectedEvent.player.contacts;

    Container getContactLinkContainer(
        String link, String asset, bool isFistLink) {
      return Container(
          margin: EdgeInsets.only(left: isFistLink ? 0 : 8),
          child: GestureDetector(
              onTap: () {
                launch(link);
              },
              child: Image.asset(asset)));
    }

    if (playerContacts != null) {
      if (playerContacts.vk != null) {
        contactLinks.add(getContactLinkContainer(playerContacts.vk,
            "assets/images/event/vk-icon.png", isFirstContact));
        isFirstContact = false;
      }

      if (playerContacts.instagram != null) {
        contactLinks.add(getContactLinkContainer(playerContacts.instagram,
            "assets/images/event/instagram-icon.png", isFirstContact));
        isFirstContact = false;
      }

      if (playerContacts.facebook != null) {
        contactLinks.add(getContactLinkContainer(playerContacts.facebook,
            "assets/images/event/facebook-icon.png", isFirstContact));
        isFirstContact = false;
      }

      if (playerContacts.telegram != null) {
        contactLinks.add(getContactLinkContainer(playerContacts.telegram,
            "assets/images/event/telegram-icon.png", isFirstContact));
        isFirstContact = false;
      }

      if (playerContacts.spotify != null) {
        contactLinks.add(getContactLinkContainer(playerContacts.spotify,
            "assets/images/event/spotify-icon.png", isFirstContact));
        isFirstContact = false;
      }
    }

    double minStep = photoSize.height / phoneHeight;

    Widget photoBlock = Container(
      height: photoSize.height,
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          image: DecorationImage(fit: BoxFit.cover, image: photo.image)),
      child: Stack(children: <Widget>[
        Positioned(
          child: Column(
            children: [
              Text(selectedEvent.player.name,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          bottom: 8,
          left: 16,
        ),
        Positioned(
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(height: 20, width: 20, color: Colors.black)),
            right: 10,
            top: 10)
      ]),
    );
    Widget contactsBlock = Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(children: [
          Row(
            children: [
              Text("My contacts",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800))
            ],
          ),
          Container(
              margin: EdgeInsets.only(top: 6),
              child: Row(children: contactLinks))
        ]));
    Widget aboutMeBlock = Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(children: [
          Row(
            children: [
              Text("About me",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800))
            ],
          ),
          Container(
              margin: EdgeInsets.only(top: 6),
              child: Row(children: [
                Text(selectedEvent.player.description,
                    style: TextStyle(color: Colors.black, fontSize: 14))
              ]))
        ]));

    List<Container> songs = List();

    bool isFirstSongBlock = true;
    for (int i = 0; i < selectedEvent.songs.length; i++) {
      songs.add(Container(
          margin: EdgeInsets.only(top: isFirstSongBlock ? 0 : 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset("assets/images/event/song-icon.png"),
            Container(
                margin: EdgeInsets.only(left: 12, top: 4),
                child: Column(
                  children: [
                    Text(selectedEvent.songs[i].name,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800)),
                    Container(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          selectedEvent.songs[i].albumName,
                          style: TextStyle(fontSize: 12),
                        ))
                  ],
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ))
          ])));
      isFirstSongBlock = false;
    }

    Widget songsBlock = Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(children: [
          Row(
            children: [
              Text("Songs",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800))
            ],
          ),
          Container(
              margin: EdgeInsets.only(top: 6), child: Column(children: songs))
        ]));

    Widget actionsBlock = Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 44),
        child: Column(children: [
          Container(
            height: 1,
            color: Colors.black,
            margin: EdgeInsets.only(bottom: 16),
          ),
          Row(
            children: [
              Image.asset("assets/images/event/hlop.png"),
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(left: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                          color: Color.fromRGBO(0, 102, 255, 1),
                        ),
                        child: Text("SEND 100Р"),
                      )))
            ],
          )
        ]));

    Container content = Container(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Container(
          color: Colors.white,
          child: Column(
              children: [photoBlock, contactsBlock, aboutMeBlock, songsBlock/*,actionsBlock*/]),
        ));

    return SingleChildScrollView(
        child: Column(children: [
      Container(height: phoneHeight - photoSize.height),
      content
    ]));
  }

  void showEventSheet(Event event) {
    setState(() {
      selectedEvent = event;
    });

    _scaffoldKey.currentState
        .showBottomSheet<void>(_bottomSheetBuilder)
        .closed
        .whenComplete(() {});
  }

  void getEvents() {
    _eventApi.getEvents().then((List<Event> events) {
      print(events.length);
      setState(() {
        this.events = events;
      });

      BitmapDescriptor.fromAssetImage(
              createLocalImageConfiguration(this.context, size: Size(80, 80)),
              "assets/images/map/shop-marker.png")
          .then((BitmapDescriptor descriptor) {
        Set<Marker> newMarkers = Set();
        for (int i = 0; i < events.length; i++) {
          Event event = events[i];

          Marker marker = Marker(
              markerId: MarkerId(jsonEncode({"eventId": event.id})),
              icon: descriptor,
              position: LatLng(event.latitude, event.longitude),
              onTap: () {
                showEventSheet(event);
              });
          newMarkers.add(marker);
        }

        setState(() {
          markers = newMarkers;
        });
      });
    });
  }

  Future getGeolocation() {
    Completer completer = Completer();
    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      CameraPosition currentPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 16);
      controller.moveCamera(CameraUpdate.newCameraPosition(currentPosition));
      completer.complete();
    }).catchError((error) {
      completer.completeError(error);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    Widget map = GoogleMap(
        compassEnabled: false,
        myLocationButtonEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: defaultPosition,
        markers: markers,
        onMapCreated: (GoogleMapController tmpController) {
          setState(() {
            controller = tmpController;
          });
          getGeolocation().catchError((error) {});
        });
    Widget mapActions = Positioned(
      right: 8,
      bottom: MediaQuery.of(context).size.height / 2 - 74,
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                controller.animateCamera(CameraUpdate.zoomIn());
              },
              child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  padding: EdgeInsets.all(14),
                  width: 44,
                  height: 44,
                  child: plusSvg)),
          GestureDetector(
            onTap: () {
              controller.animateCamera(CameraUpdate.zoomOut());
            },
            child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                padding: EdgeInsets.all(14),
                margin: EdgeInsets.only(top: 8, bottom: 8),
                width: 44,
                height: 44,
                child: minusSvg),
          ),
          GestureDetector(
              onTap: () {
                getGeolocation();
              },
              child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  padding: EdgeInsets.all(14),
                  width: 44,
                  height: 44,
                  child: findMeSvg)),
        ],
      ),
    );

    return new Scaffold(
        key: _scaffoldKey,
        body: Builder(builder: (context) {
          scaffoldContext = context;
          return Stack(children: <Widget>[map, mapActions]);
        }));
  }
}
