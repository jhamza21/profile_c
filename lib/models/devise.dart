import 'package:flutter/material.dart';

class Devise {
  final int id;
  final String name;
  final String symbol;
  final double rapport;

  Devise({
    @required this.id,
    @required this.name,
    @required this.symbol,
    @required this.rapport,
  });

  Devise.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'] ?? '',
        symbol = json['devise'] ?? '',
        rapport = json['rapport'].toDouble() ?? '';
  static List<Devise> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Devise.fromJson(value)).toList();
  }
}
