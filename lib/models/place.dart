import 'package:flutter/material.dart';

class Place {
  final String description;
  final String placeId;

  Place({@required this.description, @required this.placeId});

  Place.fromJson(Map<String, dynamic> json)
      : description = json['description'],
        placeId = json['place_id'];
  static List<Place> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Place.fromJson(value)).toList();
  }
}
