import 'package:flutter/material.dart';

class QcmLevel {
  final int id;
  final String title;
  String time;

  QcmLevel({
    @required this.id,
    @required this.title,
    @required this.time,
  });
  QcmLevel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['name'],
        time = json['pivot'] != null ? json['pivot']['time'] : '';
  static List<QcmLevel> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => QcmLevel.fromJson(value)).toList();
  }
}
