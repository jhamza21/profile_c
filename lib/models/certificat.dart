import 'package:flutter/material.dart';
import 'package:profilecenter/models/company.dart';

class Certificat {
  final int id;
  final String title;
  final String delivered;
  final String validity;
  final Company company;
  final String companyName;

  Certificat({
    @required this.id,
    @required this.title,
    @required this.delivered,
    @required this.validity,
    @required this.company,
    @required this.companyName,
  });
  Certificat.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'] ?? '',
        delivered = json['taken_date'] ?? '',
        validity = json['validity'] ?? null,
        companyName = json['entreprise_name'] ?? null,
        company = json['entreprise'] != null
            ? Company.fromJson(json['entreprise'])
            : null;
  static List<Certificat> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Certificat.fromJson(value)).toList();
  }
}
