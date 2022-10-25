import 'package:flutter/material.dart';

class Payment {
  final int id;
  final double amount;
  final int nbDays;
  final String date;
  final String time;

  Payment({
    @required this.id,
    @required this.amount,
    @required this.nbDays,
    @required this.date,
    @required this.time,
  });

  Payment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        amount = json['amount'].toDouble(),
        nbDays = json['nb_jrs'] ?? null,
        time = json['created_at'].substring(11, 16),
        date = json['created_at'].substring(0, 10);

  static List<Payment> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Payment.fromJson(value)).toList();
  }
}
