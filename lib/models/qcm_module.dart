import 'package:flutter/material.dart';
import 'package:profilecenter/models/qcm_level.dart';

class QcmModule {
  final int id;
  final String title;
  final List<QcmLevel> levels;

  QcmModule({@required this.id, @required this.title, @required this.levels});
  QcmModule.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        levels = QcmLevel.listFromJson(json['levels']);
  static List<QcmModule> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => QcmModule.fromJson(value)).toList();
  }
}
