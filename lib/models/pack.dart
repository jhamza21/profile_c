import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_days_between_dates.dart';

class Pack {
  final int id;
  final String name;
  final List<String> notAllowed;
  final double prix;

  Pack({
    @required this.id,
    @required this.name,
    @required this.notAllowed,
    @required this.prix,
  });

  static Pack fromJson(Map<String, dynamic> json, String createdAt) {
    List<String> _notAllowed = List<String>.from(
        json['permission_packages'].map((e) => e["name"]).toList());
    //id==1 : pack freelance free
    //check free validity
    if (json['id'] == 1 && createdAt != null) {
      int days = getDays(createdAt.substring(0, 10),
          DateFormat('yyyy-MM-dd').format(DateTime.now()));
      if (days > 730)
        _notAllowed = [
          CALENDAR_PRIVILEGE,
          CHAT_PRIVILEGE,
          POSTULATE_PRIVILEGE,
          QCM_PRIVILEGE
        ];
    }
    return Pack(
        id: json['id'],
        name: json['name'] ?? '',
        notAllowed: _notAllowed,
        prix: json['amount'].toDouble());
  }

  static List<Pack> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Pack.fromJson(value, null)).toList();
  }
}
