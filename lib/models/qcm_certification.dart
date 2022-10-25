import 'package:flutter/material.dart';

class QcmCertification {
  final int id;
  final String moduleName;
  final String levelName;
  final String status;
  final double seuil;
  final String createdAt;
  final double mark;

  QcmCertification(
      {@required this.id,
      @required this.moduleName,
      @required this.levelName,
      @required this.status,
      @required this.seuil,
      @required this.createdAt,
      @required this.mark});
  QcmCertification.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        moduleName = json['module_name'],
        levelName = json['qcm_level_name'],
        status = json['status'],
        seuil = json['seuil'] != null
            ? double.parse(json['seuil'].toString())
            : null,
        createdAt = json['created_at'].substring(0, 10),
        mark = double.parse(json['moyenne'].toString());
  static List<QcmCertification> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => QcmCertification.fromJson(value)).toList();

  }
}
