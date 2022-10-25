import 'package:flutter/material.dart';

class Address {
  int id;
  String description;
  String country;
  String region;
  double lat;
  double lon;

  Address(
      {this.id,
      @required this.description,
      @required this.country,
      @required this.region,
      @required this.lat,
      @required this.lon});

  String getCountry(List jsonData) {
    var res = jsonData.firstWhere(
        (element) => element["types"].contains("country") == true,
        orElse: () => null);
    return res == null ? null : res['long_name'];
  }

  String getRegion(List jsonData) {
    var res = jsonData.firstWhere(
        (element) =>
            element["types"].contains("administrative_area_level_1") == true,
        orElse: () => null);
    return res == null ? null : res['long_name'];
  }

  Address.fromJsonGoogle(Map<String, dynamic> json) {
    description = json['formatted_address'];
    region = getRegion(json['address_components']);
    country = getCountry(json['address_components']);
    lat = json['geometry']['location']['lat'];
    lon = json['geometry']['location']['lng'];
  }

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    region = json['region'];
    country = json['country'];
    lat = json['latitude'];
    lon = json['longtitude'];
  }
}
