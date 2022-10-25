import 'package:flutter/material.dart';

class Company {
  final int id;
  String name;
  String image;
  String mobile;

  Company(
      {@required this.id,
      @required this.name,
      @required this.image,
      @required this.mobile});

  Company.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'] ?? '',
        image = json['logo'] ?? '',
        mobile = json['phone'] ?? '';

  static List<Company> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Company.fromJson(value)).toList();
  }
}
