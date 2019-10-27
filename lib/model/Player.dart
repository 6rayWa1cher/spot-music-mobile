
import 'package:flutter/widgets.dart';

import 'PlayerContacts.dart';

class Player {
  String name;
  Image photo;
  Size photoSize;
  PlayerContacts contacts;
  String description;

  Player({this.name, this.photo, this.photoSize, this.contacts, this.description});
}